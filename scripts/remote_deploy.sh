#!/usr/bin/env bash
# Deploy remoto no Mac always-on — chamado por `cf deploy mobile` via SSH.
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
#   1. flock (um deploy por vez)
#   2. git fetch + checkout --ref + pull --ff-only
#   3. android/web → scripts/distribute.sh
#   4. ios → scripts/distribute.sh ios --testflight (TestFlight)
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

usage() {
  sed -n '2,22p' "$0"
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

run_android() {
  echo
  echo "==> Android → App Distribution (flutter-testers)"
  ./scripts/distribute.sh android "${DIST_ARGS[@]+"${DIST_ARGS[@]}"}"
}

run_ios_testflight() {
  echo
  echo "==> iOS → TestFlight"
  ./scripts/distribute.sh ios --testflight "${DIST_ARGS[@]+"${DIST_ARGS[@]}"}"
}

run_web() {
  echo
  echo "==> Web → Hosting canal testers"
  ./scripts/distribute.sh web "${DIST_ARGS[@]+"${DIST_ARGS[@]}"}"
}

status=0
case "$PLATFORM" in
  android) run_android || status=$? ;;
  ios) run_ios_testflight || status=$? ;;
  web) run_web || status=$? ;;
  both)
    run_android || status=$?
    run_ios_testflight || status=$?
    ;;
  all)
    run_android || status=$?
    run_ios_testflight || status=$?
    run_web || status=$?
    ;;
esac

if [[ "$status" -ne 0 ]]; then
  echo "remote_deploy terminou com erros (exit $status)." >&2
  exit "$status"
fi
echo
echo "remote_deploy OK."
