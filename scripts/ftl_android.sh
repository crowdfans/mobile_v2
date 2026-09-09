#!/usr/bin/env bash
# CF-125 / CF-126 — Firebase Test Lab (Android) + Patrol instrumentation.
#
# Builds app + androidTest APKs via Patrol and submits to FTL on crowdfans-prod.
#
# Uso:
#   ./scripts/ftl_android.sh
#   ./scripts/ftl_android.sh --dry-run
#   ./scripts/ftl_android.sh --skip-build
#   PATROL_TEST=integration_test/superfan_onboarding_login_test.dart ./scripts/ftl_android.sh
#
# Pré-requisitos:
#   - gcloud autenticado (user: `gcloud auth login` OU SA via
#     `GOOGLE_APPLICATION_CREDENTIALS` / `gcloud auth activate-service-account`)
#   - Projeto crowdfans-prod com testing.googleapis.com + toolresults.googleapis.com
#   - patrol_cli (`dart pub global activate patrol_cli`)
#   - Flutter no PATH (ou FLUTTER_ROOT / PATH com sdk/flutter/bin)
#
# Auth recomendada no CI: service account com papéis
#   - Firebase Test Lab Admin (roles/cloudtestservice.testAdmin)
#   - Storage Object Admin no bucket de resultados (se restringir)
# Não commitar JSON de SA — exportar GOOGLE_APPLICATION_CREDENTIALS localmente.
#
# iOS (CF-127): ainda bloqueado em signing Apple — ver PENDENCIA.md.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

export PATH="${FLUTTER_ROOT:-$HOME/sdk/flutter}/bin:$HOME/.pub-cache/bin:${PATH:-}"

PROJECT="${FIREBASE_PROJECT:-crowdfans-prod}"
TEST_TARGET="${PATROL_TEST:-integration_test/smoke_test.dart}"
DEVICE_MODEL="${FTL_DEVICE_MODEL:-MediumPhone.arm}"
DEVICE_VERSION="${FTL_DEVICE_VERSION:-34}"
LOCALE="${FTL_LOCALE:-pt_BR}"
ORIENTATION="${FTL_ORIENTATION:-portrait}"
TIMEOUT="${FTL_TIMEOUT:-10m}"
RESULTS_DIR="${FTL_RESULTS_DIR:-build/ftl-android-results}"
APP_APK="${FTL_APP_APK:-build/app/outputs/apk/debug/app-debug.apk}"
TEST_APK="${FTL_TEST_APK:-build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk}"

DRY_RUN=0
SKIP_BUILD=0
EXTRA_DART_DEFINES=()

usage() {
  sed -n '2,28p' "$0"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    --skip-build) SKIP_BUILD=1 ;;
    --target)
      shift
      TEST_TARGET="${1:-}"
      [[ -n "$TEST_TARGET" ]] || { echo "Falta valor para --target"; exit 1; }
      ;;
    --dart-define=*)
      EXTRA_DART_DEFINES+=("$1")
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Argumento desconhecido: $1"
      usage
      exit 1
      ;;
  esac
  shift
done

echo "==> CrowdFans FTL Android"
echo "    project=$PROJECT"
echo "    test=$TEST_TARGET"
echo "    device=$DEVICE_MODEL:$DEVICE_VERSION ($LOCALE/$ORIENTATION)"
echo "    app_apk=$APP_APK"
echo "    test_apk=$TEST_APK"

if ! command -v gcloud >/dev/null 2>&1; then
  echo "gcloud não encontrado. Instale o Google Cloud SDK e autentique:"
  echo "  gcloud auth login"
  echo "  gcloud config set project $PROJECT"
  exit 1
fi

if ! command -v patrol >/dev/null 2>&1; then
  echo "patrol CLI não encontrado. Ative com:"
  echo "  dart pub global activate patrol_cli"
  exit 1
fi

ACTIVE_ACCOUNT="$(gcloud auth list --filter=status:ACTIVE --format='value(account)' 2>/dev/null || true)"
if [[ -z "$ACTIVE_ACCOUNT" && -z "${GOOGLE_APPLICATION_CREDENTIALS:-}" ]]; then
  echo "Sem conta gcloud ativa e sem GOOGLE_APPLICATION_CREDENTIALS."
  echo "  gcloud auth login"
  echo "  # ou: export GOOGLE_APPLICATION_CREDENTIALS=/caminho/sa-ftl.json"
  exit 1
fi
echo "    auth=${ACTIVE_ACCOUNT:-SA via GOOGLE_APPLICATION_CREDENTIALS}"

echo
echo "==> Verificando acesso FTL (models list)…"
if ! gcloud firebase test android models list --project "$PROJECT" >/dev/null; then
  echo "Falha ao listar models FTL no projeto $PROJECT."
  echo "Confira APIs testing.googleapis.com / toolresults.googleapis.com e billing."
  exit 1
fi
echo "    models list OK"

BUILD_CMD=(patrol build android --target "$TEST_TARGET")
for define in "${EXTRA_DART_DEFINES[@]+"${EXTRA_DART_DEFINES[@]}"}"; do
  BUILD_CMD+=("$define")
done

RUN_CMD=(
  gcloud firebase test android run
  --type instrumentation
  --app "$APP_APK"
  --test "$TEST_APK"
  --device "model=${DEVICE_MODEL},version=${DEVICE_VERSION},locale=${LOCALE},orientation=${ORIENTATION}"
  --timeout "$TIMEOUT"
  --project "$PROJECT"
  --results-dir "$RESULTS_DIR"
  --client-details "matrixLabel=crowdfans-patrol-${TEST_TARGET##*/}"
)

echo
echo "Build:"
printf '  %q' "${BUILD_CMD[@]}"
echo
echo "Submit:"
printf '  %q' "${RUN_CMD[@]}"
echo
echo
echo "Smoke local (sem FTL): patrol test -t $TEST_TARGET"
echo "iOS FTL (CF-127): bloqueado — signing Apple em PENDENCIA.md."

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo
  echo "[dry-run] não executou patrol build nem gcloud firebase test."
  exit 0
fi

if [[ "$SKIP_BUILD" -eq 0 ]]; then
  # pubspec declara asset `.env` (gitignored). Sem arquivo o Gradle falha.
  if [[ ! -f .env ]]; then
    if [[ -f .env.example ]]; then
      echo "==> Criando .env a partir de .env.example (não commitado)"
      cp .env.example .env
    else
      echo "Falta .env (asset do Flutter). Copie .env.example → .env."
      exit 1
    fi
  fi
  echo
  echo "==> patrol build android…"
  "${BUILD_CMD[@]}"
else
  echo
  echo "==> --skip-build: reutilizando APKs existentes"
fi

if [[ ! -f "$APP_APK" || ! -f "$TEST_APK" ]]; then
  echo "APKs não encontrados:"
  echo "  $APP_APK"
  echo "  $TEST_APK"
  echo "Rode sem --skip-build ou ajuste FTL_APP_APK / FTL_TEST_APK."
  exit 1
fi

echo
echo "==> Submetendo ao Firebase Test Lab…"
mkdir -p "$(dirname "$RESULTS_DIR")"
"${RUN_CMD[@]}"
echo
echo "FTL submit concluído. Resultados locais em: $RESULTS_DIR"
echo "Console: https://console.firebase.google.com/project/${PROJECT}/testlab/histories"
