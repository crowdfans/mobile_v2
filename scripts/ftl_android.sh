#!/usr/bin/env bash
# CF-125 / CF-126 — placeholder Firebase Test Lab (Android) + Patrol.
#
# NÃO marca Done: exige Testing API, billing/SA e `gcloud` autenticado em
# `crowdfans-prod` (ver docs/YOUTRACK_BACKLOG.md §1.2). Este script só documenta
# o fluxo esperado quando a infra estiver pronta.
#
# Uso (quando FTL estiver habilitado):
#   ./scripts/ftl_android.sh
#   ./scripts/ftl_android.sh --dry-run
#
# Pré-requisitos:
#   - gcloud CLI logado no projeto crowdfans-prod
#   - API testing.googleapis.com habilitada
#   - Service account com papel Test Lab Admin (ou equivalente)
#   - Emulador/device NÃO é necessário — o FTL roda na nuvem
#   - Credenciais E2E via --dart-define (ou arquivo JSON --dart-define-from-file)

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

PROJECT="${FIREBASE_PROJECT:-crowdfans-prod}"
TEST_TARGET="${PATROL_TEST:-integration_test/smoke_test.dart}"
DEVICE_MODEL="${FTL_DEVICE_MODEL:-MediumPhone.arm}"
DEVICE_VERSION="${FTL_DEVICE_VERSION:-34}"
LOCALE="${FTL_LOCALE:-pt_BR}"
ORIENTATION="${FTL_ORIENTATION:-portrait}"
DRY_RUN=0

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --help|-h)
      sed -n '2,25p' "$0"
      exit 0
      ;;
  esac
done

echo "==> CrowdFans FTL Android (placeholder)"
echo "    project=$PROJECT"
echo "    test=$TEST_TARGET"
echo "    device=$DEVICE_MODEL:$DEVICE_VERSION"

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

echo
echo "Passos manuais / quando a API estiver ok:"
echo "  1) patrol build android --target \"$TEST_TARGET\" [--dart-define=...]"
echo "  2) gcloud firebase test android run \\"
echo "       --type instrumentation \\"
echo "       --app build/app/outputs/apk/debug/app-debug.apk \\"
echo "       --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk \\"
echo "       --device model=$DEVICE_MODEL,version=$DEVICE_VERSION,locale=$LOCALE,orientation=$ORIENTATION \\"
echo "       --project $PROJECT"
echo
echo "Smoke local (sem FTL):"
echo "  patrol test -t integration_test/smoke_test.dart"

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo
  echo "[dry-run] não executou gcloud nem patrol build."
  exit 0
fi

echo
echo "Abortando: FTL ainda não confirmado no crowdfans-prod (CF-125)."
echo "Rode com --dry-run para só imprimir o roteiro, ou habilite a infra e"
echo "adapte este script para chamar patrol build + gcloud firebase test."
exit 2
