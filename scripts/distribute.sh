#!/usr/bin/env bash
# Gera o APK (e o IPA, se o signing existir) e envia ao Firebase App Distribution.
#
# Uso:
#   npm run distribute              # Android (padrão)
#   npm run distribute:ios
#   npm run distribute:all
#   ./scripts/distribute.sh android --notes "o que mudou"
#   ./scripts/distribute.sh android --skip-build
#
# Variáveis opcionais: BUILD_NAME, BUILD_NUMBER, RELEASE_NOTES, JAVA_HOME, ANDROID_HOME, FLUTTER.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

ANDROID_APP_ID='1:658897248078:android:edd3c987eb54bcdc2c881f'
IOS_APP_ID='1:658897248078:ios:874725d168494cab2c881f'
FIREBASE_PROJECT='crowdfans-prod'
TESTER_GROUP='flutter-testers'
APK_PATH='build/app/outputs/flutter-apk/app-release.apk'

PLATFORM='android'
SKIP_BUILD=0
NOTES="${RELEASE_NOTES:-}"

usage() {
  sed -n '2,12p' "$0"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    android | ios | all)
      PLATFORM="$1"
      shift
      ;;
    --skip-build)
      SKIP_BUILD=1
      shift
      ;;
    --notes)
      NOTES="${2:-}"
      shift 2
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

if [[ -z "$NOTES" ]]; then
  NOTES="$(git -C "$ROOT" log -1 --pretty='%s' 2>/dev/null || echo 'Build Flutter para testers')"
fi

export PATH="$ROOT/node_modules/.bin:${FLUTTER_SDK:-$HOME/sdk/flutter}/bin:$HOME/sdk/flutter/bin:$PATH"

if [[ -z "${JAVA_HOME:-}" ]]; then
  for jdk in "$HOME/Library/Java/JavaVirtualMachines"/*/Contents/Home; do
    if [[ -x "$jdk/bin/java" ]]; then
      export JAVA_HOME="$jdk"
      break
    fi
  done
fi

if [[ -z "${ANDROID_HOME:-}" && -d "$HOME/Library/Android/sdk" ]]; then
  export ANDROID_HOME="$HOME/Library/Android/sdk"
  export ANDROID_SDK_ROOT="$ANDROID_HOME"
fi

if ! command -v firebase >/dev/null 2>&1; then
  echo "firebase-tools não encontrado. Rode: npm install" >&2
  exit 1
fi

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter não está no PATH. Exporte PATH=\"\$HOME/sdk/flutter/bin:\$PATH\"" >&2
  exit 1
fi

if ! firebase projects:list --project "$FIREBASE_PROJECT" >/dev/null 2>&1; then
  echo "Firebase CLI sem sessão. Rode: npm run firebase:login" >&2
  exit 1
fi

pubspec_version="$(awk '/^version:/ { print $2; exit }' pubspec.yaml)"
build_name="${BUILD_NAME:-${pubspec_version%%+*}}"
if [[ -n "${BUILD_NUMBER:-}" ]]; then
  build_number="$BUILD_NUMBER"
else
  commit_count="$(git -C "$ROOT" rev-list --count HEAD 2>/dev/null || echo 1)"
  stamp="$(date +%H%M)"
  build_number="${commit_count}${stamp}"
fi

has_ios_signing() {
  local identities
  identities="$(security find-identity -v -p codesigning 2>/dev/null || true)"
  [[ "$identities" == *"Apple Development"* || "$identities" == *"Apple Distribution"* ]]
}

upload_ios() {
  shopt -s nullglob
  local ipas=(build/ios/ipa/*.ipa)
  shopt -u nullglob
  if [[ ${#ipas[@]} -eq 0 ]]; then
    echo "IPA não encontrado em build/ios/ipa/" >&2
    return 1
  fi
  echo "→ App Distribution iOS ($TESTER_GROUP)"
  firebase appdistribution:distribute "${ipas[0]}" \
    --app "$IOS_APP_ID" \
    --groups "$TESTER_GROUP" \
    --project "$FIREBASE_PROJECT" \
    --release-notes "$NOTES"
}

build_android() {
  echo "→ APK $build_name ($build_number)"
  flutter build apk --release \
    --build-name="$build_name" \
    --build-number="$build_number"
}

upload_android() {
  if [[ ! -f "$APK_PATH" ]]; then
    echo "APK não encontrado: $APK_PATH" >&2
    exit 1
  fi
  echo "→ App Distribution Android ($TESTER_GROUP)"
  firebase appdistribution:distribute "$APK_PATH" \
    --app "$ANDROID_APP_ID" \
    --groups "$TESTER_GROUP" \
    --project "$FIREBASE_PROJECT" \
    --release-notes "$NOTES"
}

build_ios() {
  if ! has_ios_signing; then
    echo "iOS pulado: não há certificado Apple no Keychain. Veja PENDENCIA.md." >&2
    return 1
  fi
  echo "→ IPA $build_name ($build_number)"
  flutter build ipa --release --export-method ad-hoc \
    --build-name="$build_name" \
    --build-number="$build_number"
}

run_android() {
  if [[ "$SKIP_BUILD" -eq 0 ]]; then
    build_android
  fi
  upload_android
}

run_ios() {
  if [[ "$SKIP_BUILD" -eq 0 ]]; then
    build_ios || return 1
  fi
  upload_ios
}

echo "CrowdFans → App Distribution ($FIREBASE_PROJECT / $TESTER_GROUP)"
echo "Notas: $NOTES"

status=0
case "$PLATFORM" in
  android) run_android ;;
  ios) run_ios || status=1 ;;
  all)
    run_android
    run_ios || echo "Android enviado; iOS não."
    ;;
esac

exit "$status"
