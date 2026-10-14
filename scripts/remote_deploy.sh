#!/usr/bin/env bash
# Deploy remoto no Mac always-on — chamado por `cf deploy mobile` via SSH.
# Product UX: o caller só roda `cf deploy mobile`; Flutter/Xcode/SDK ficam aqui.
#
# Uso (no Mac, a partir do checkout mobile_v2):
#   ./scripts/remote_deploy.sh
#   ./scripts/remote_deploy.sh --platform android
#   ./scripts/remote_deploy.sh --platform ios
#   ./scripts/remote_deploy.sh --platform web
#   ./scripts/remote_deploy.sh --platform both
#   ./scripts/remote_deploy.sh --platform all
#   ./scripts/remote_deploy.sh --ref prod --dry-run
#   ./scripts/remote_deploy.sh --notes "o que mudou"
#
# Fluxo:
#   1. mkdir lock (um deploy por vez; portátil no macOS)
#   2. git fetch + checkout --ref + pull --ff-only
#   3. android/web → scripts/distribute.sh
#   4. ios → scripts/distribute.sh ios --testflight (TestFlight)
#
# Multi-platform (both/all): continua após um fail e imprime resumo por
# plataforma no final (ok|fail + última linha de erro). Exit 1 se qualquer
# plataforma falhou — o sucesso do web no final não esconde android/ios.
#
# API do Flutter web permanece crowdfans-server-prod (ver distribute.sh).
# Secrets (Firebase / ASC) só neste Mac — nunca no laptop.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

PLATFORM='all'
REF='prod'
DRY_RUN=0
NOTES="${RELEASE_NOTES:-}"
# mkdir lock — portátil no macOS (util-linux flock não vem no Darwin).
LOCK_DIR="${TMPDIR:-/tmp}/crowdfans-mobile-remote-deploy.lock"

# Marcadores parseados por `cf deploy mobile` (não traduzir).
SUMMARY_BEGIN='CF_PLATFORM_SUMMARY_BEGIN'
SUMMARY_END='CF_PLATFORM_SUMMARY_END'

usage() {
  sed -n '2,26p' "$0"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --platform)
      PLATFORM="${2:-}"
      shift 2
      ;;
    --ref)
      REF="${2:-}"
      shift 2
      ;;
    --notes)
      NOTES="${2:-}"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "Opção desconhecida: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

case "$PLATFORM" in
  android | ios | apple | web | both | all) ;;
  *)
    echo "platform inválida: $PLATFORM (android|ios|apple|web|both|all)" >&2
    exit 1
    ;;
esac
if [[ "$PLATFORM" == "apple" ]]; then
  PLATFORM='ios'
fi

if [[ -z "$REF" || "$REF" =~ [[:space:]] ]]; then
  echo "ref inválida: $REF" >&2
  exit 1
fi

echo "CrowdFans remote_deploy"
echo "  root:     $ROOT"
echo "  ref:      $REF"
echo "  platform: $PLATFORM"
echo "  dry-run:  $DRY_RUN"

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo
  echo "[dry-run] plano:"
  echo "  mkdir-lock $LOCK_DIR"
  echo "  git fetch origin"
  echo "  git checkout $REF"
  echo "  git pull --ff-only origin $REF"
  case "$PLATFORM" in
    android) echo "  ./scripts/distribute.sh android" ;;
    ios) echo "  ./scripts/distribute.sh ios --testflight" ;;
    web) echo "  ./scripts/distribute.sh web" ;;
    both)
      echo "  ./scripts/distribute.sh android"
      echo "  ./scripts/distribute.sh ios --testflight"
      ;;
    all)
      echo "  ./scripts/distribute.sh android"
      echo "  ./scripts/distribute.sh ios --testflight"
      echo "  ./scripts/distribute.sh web"
      ;;
  esac
  echo "[dry-run] sem git pull / build / upload."
  exit 0
fi

release_lock() {
  rmdir "$LOCK_DIR" 2>/dev/null || true
}
if ! mkdir "$LOCK_DIR" 2>/dev/null; then
  echo "Outro remote_deploy está em andamento (lock: $LOCK_DIR)." >&2
  exit 1
fi
trap release_lock EXIT INT TERM

echo
echo "→ git fetch / checkout $REF / pull --ff-only"
git fetch origin
git checkout "$REF"
git pull --ff-only origin "$REF"

DIST_ARGS=()
if [[ -n "$NOTES" ]]; then
  DIST_ARGS+=(--notes "$NOTES")
fi

# Linhas "name|ok|" ou "name|fail|última mensagem" — impressas no resumo final.
PLATFORM_RESULTS=()

# Última linha útil do log (ignora spinners/checkmarks do Firebase).
last_error_line() {
  local log="$1"
  awk '
    NF {
      line = $0
      gsub(/\r/, "", line)
      # ignora progresso visual comum
      if (line ~ /^(→|==>|✔|✓|✔️|i |\[.*\] (dns|tcp|ssh|plan|info))/) next
      if (line ~ /^CrowdFans /) next
      if (line ~ /^  (root|ref|platform|dry-run|Notas):/) next
      useful = line
    }
    END { if (useful != "") print useful }
  ' "$log"
}

# Roda um passo de plataforma: tee o log, continua mesmo com fail, registra resultado.
run_tracked() {
  local name="$1"
  shift
  local log ec last
  log="$(mktemp "${TMPDIR:-/tmp}/cf-remote-deploy-${name}.XXXXXX")"
  set +e
  # PIPESTATUS[0] = exit do distribute.sh (não do tee).
  "$@" 2>&1 | tee "$log"
  ec=${PIPESTATUS[0]}
  set -e
  if [[ "$ec" -eq 0 ]]; then
    PLATFORM_RESULTS+=("${name}|ok|")
    echo "[ok] $name"
  else
    last="$(last_error_line "$log")"
    if [[ -z "$last" ]]; then
      last="exit $ec (sem mensagem capturada — role o log acima)"
    fi
    PLATFORM_RESULTS+=("${name}|fail|${last}")
    echo "[fail] $name — $last" >&2
  fi
  rm -f "$log"
  return 0
}

run_android() {
  echo
  echo "==> Android → App Distribution (flutter-testers)"
  run_tracked android ./scripts/distribute.sh android "${DIST_ARGS[@]+"${DIST_ARGS[@]}"}"
}

run_ios_testflight() {
  echo
  echo "==> iOS → TestFlight"
  run_tracked ios ./scripts/distribute.sh ios --testflight "${DIST_ARGS[@]+"${DIST_ARGS[@]}"}"
}

run_web() {
  echo
  echo "==> Web → Hosting canal testers"
  run_tracked web ./scripts/distribute.sh web "${DIST_ARGS[@]+"${DIST_ARGS[@]}"}"
}

# Imprime resumo humano + bloco parseável (cf deploy mobile).
print_platform_summary() {
  local entry name result detail failed=0 ok_list=() fail_list=()
  echo
  echo "======== platform summary ========"
  echo "$SUMMARY_BEGIN"
  for entry in "${PLATFORM_RESULTS[@]}"; do
    name="${entry%%|*}"
    rest="${entry#*|}"
    result="${rest%%|*}"
    detail="${rest#*|}"
    if [[ "$result" == "ok" ]]; then
      echo "${name}: ok"
      echo "[ok]   ${name}"
      ok_list+=("$name")
    else
      echo "${name}: fail | ${detail}"
      echo "[fail] ${name} — ${detail}"
      fail_list+=("$name")
      failed=1
    fi
  done
  echo "$SUMMARY_END"
  echo "======== end platform summary ========"
  if [[ "$failed" -eq 0 ]]; then
    echo "remote_deploy OK (${#ok_list[@]} platform(s): ${ok_list[*]})."
    return 0
  fi
  echo "remote_deploy terminou com erros (${#fail_list[@]} failed: ${fail_list[*]}; ok: ${ok_list[*]:-none})." >&2
  echo "Re-run one platform: cf deploy mobile --platform <android|ios|web>" >&2
  return 1
}

case "$PLATFORM" in
  android) run_android ;;
  ios) run_ios_testflight ;;
  web) run_web ;;
  both)
    run_android
    run_ios_testflight
    ;;
  all)
    run_android
    run_ios_testflight
    run_web
    ;;
esac

if ! print_platform_summary; then
  exit 1
fi
exit 0
