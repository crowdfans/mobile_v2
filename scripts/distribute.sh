#!/usr/bin/env bash
# Gera o APK (IPA se houver signing) e envia ao App Distribution.
# Web vai para o Firebase Hosting (canal testers) — App Distribution não aceita web.
# iOS com --testflight → IPA app-store + upload TestFlight (ASC no Mac).
#
# Uso:
#   npm run distribute              # Android (padrão)
#   npm run distribute:ios
#   npm run distribute:ios:testflight
#   npm run distribute:web
#   npm run distribute:all
#   ./scripts/distribute.sh android --notes "o que mudou"
#   ./scripts/distribute.sh ios --testflight
#   ./scripts/distribute.sh web --skip-build
#
# Variáveis opcionais: BUILD_NAME, BUILD_NUMBER, RELEASE_NOTES, JAVA_HOME, ANDROID_HOME, FLUTTER.
# TestFlight (Mac, não commitar): ASC_API_KEY_ID + ASC_API_ISSUER_ID + ASC_API_KEY_PATH
#   ou ASC_USERNAME + ASC_APP_SPECIFIC_PASSWORD.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

ANDROID_APP_ID='1:658897248078:android:edd3c987eb54bcdc2c881f'
IOS_APP_ID='1:658897248078:ios:874725d168494cab2c881f'
FIREBASE_PROJECT='crowdfans-prod'
TESTER_GROUP='flutter-testers'
WEB_CHANNEL='testers'
WEB_EXPIRES='14d'
APK_PATH='build/app/outputs/flutter-apk/app-release.apk'
WEB_INDEX='build/web/index.html'
# API viva — nunca crowdfans-app-dev* / crowdfans-app-prod.
API_PROD_BASE_URL='https://crowdfans-server-prod-h9qb6.ondigitalocean.app'

PLATFORM='android'
SKIP_BUILD=0
TESTFLIGHT=0
NOTES="${RELEASE_NOTES:-}"

usage() {
  sed -n '2,20p' "$0"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    android | ios | web | all)
      PLATFORM="$1"
      shift
      ;;
    --skip-build)
      SKIP_BUILD=1
      shift
      ;;
    --testflight)
      TESTFLIGHT=1
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

first_ipa() {
  shopt -s nullglob
  local ipas=(build/ios/ipa/*.ipa)
  shopt -u nullglob
  if [[ ${#ipas[@]} -eq 0 ]]; then
    echo "IPA não encontrado em build/ios/ipa/" >&2
    return 1
  fi
  printf '%s\n' "${ipas[0]}"
}

upload_ios_app_distribution() {
  local ipa
  ipa="$(first_ipa)" || return 1
  echo "→ App Distribution iOS ($TESTER_GROUP)"
  firebase appdistribution:distribute "$ipa" \
    --app "$IOS_APP_ID" \
    --groups "$TESTER_GROUP" \
    --project "$FIREBASE_PROJECT" \
    --release-notes "$NOTES"
}

# Upload IPA to TestFlight via App Store Connect.
# Prefer API key (.p8); fallback app-specific password.
# TODO(Mac): confirmar qual credencial Gustavo já tem no Keychain/ASC e
# documentar o path do .p8 em ~/.config ou env do launchd — sem inventar secrets.
upload_ios_testflight() {
  local ipa
  ipa="$(first_ipa)" || return 1

  if ! command -v xcrun >/dev/null 2>&1; then
    echo "xcrun não encontrado (precisa macOS + Xcode CLT)." >&2
    return 1
  fi

  echo "→ TestFlight upload: $ipa"

  if [[ -n "${ASC_API_KEY_ID:-}" && -n "${ASC_API_ISSUER_ID:-}" ]]; then
    # altool procura AuthKey_<KEY_ID>.p8 em:
    #   ./private_keys, ~/private_keys, ~/.private_keys, ~/.appstoreconnect/private_keys
    local key_name="AuthKey_${ASC_API_KEY_ID}.p8"
    if [[ -n "${ASC_API_KEY_PATH:-}" ]]; then
      if [[ ! -f "$ASC_API_KEY_PATH" ]]; then
        echo "ASC_API_KEY_PATH não existe: $ASC_API_KEY_PATH" >&2
        return 1
      fi
      mkdir -p "$HOME/.appstoreconnect/private_keys"
      local dest="$HOME/.appstoreconnect/private_keys/$key_name"
      if [[ ! -e "$dest" ]]; then
        ln -sf "$ASC_API_KEY_PATH" "$dest"
        echo "→ symlink ASC key → $dest"
      fi
    fi
    # altool ainda cobre upload de IPA; migrar para transporter/API se Apple remover.
    xcrun altool --upload-app \
      --type ios \
      --file "$ipa" \
      --apiKey "$ASC_API_KEY_ID" \
      --apiIssuer "$ASC_API_ISSUER_ID"
    return 0
  fi

  if [[ -n "${ASC_USERNAME:-}" && -n "${ASC_APP_SPECIFIC_PASSWORD:-}" ]]; then
    xcrun altool --upload-app \
      --type ios \
      --file "$ipa" \
      -u "$ASC_USERNAME" \
      -p "$ASC_APP_SPECIFIC_PASSWORD"
    return 0
  fi

  cat >&2 <<'EOF'
TestFlight: faltam credenciais ASC neste Mac.

Defina (não commitar):
  export ASC_API_KEY_ID='...'
  export ASC_API_ISSUER_ID='...'
  export ASC_API_KEY_PATH="$HOME/.private_keys/AuthKey_XXXXXX.p8"

ou:
  export ASC_USERNAME='apple-id@...'
  export ASC_APP_SPECIFIC_PASSWORD='xxxx-xxxx-xxxx-xxxx'

IPA já gerado em build/ios/ipa/ — dá para subir manualmente pelo Transporter
enquanto o env não estiver configurado.
EOF
  return 1
}

upload_ios() {
  if [[ "$TESTFLIGHT" -eq 1 ]]; then
    upload_ios_testflight
  else
    upload_ios_app_distribution
  fi
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
  local export_method='ad-hoc'
  if [[ "$TESTFLIGHT" -eq 1 ]]; then
    export_method='app-store'
  fi
  echo "→ IPA $build_name ($build_number) export-method=$export_method"
  flutter build ipa --release --export-method "$export_method" \
    --build-name="$build_name" \
    --build-number="$build_number"
}

build_web() {
  echo "→ Web $build_name ($build_number)"
  flutter build web --release \
    --dart-define=API_BASE_URL="$API_PROD_BASE_URL" \
    --build-name="$build_name" \
    --build-number="$build_number"
}

upload_web() {
  if [[ ! -f "$WEB_INDEX" ]]; then
    echo "Build web não encontrada: $WEB_INDEX" >&2
    echo "Rode sem --skip-build, ou: flutter build web --release" >&2
    exit 1
  fi
  echo "→ Hosting canal $WEB_CHANNEL (expira em $WEB_EXPIRES)"
  echo "  Notas: $NOTES"
  firebase hosting:channel:deploy "$WEB_CHANNEL" \
    --project "$FIREBASE_PROJECT" \
    --expires "$WEB_EXPIRES"
  echo
  echo "Cole o host do URL acima em Authentication → Authorized domains."
  echo "OTP no browser ainda precisa do reCAPTCHA (PENDENCIA.md)."
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

run_web() {
  if [[ "$SKIP_BUILD" -eq 0 ]]; then
    build_web
  fi
  upload_web
}

if [[ "$TESTFLIGHT" -eq 1 && "$PLATFORM" != "ios" && "$PLATFORM" != "all" ]]; then
  echo "--testflight só se aplica a ios (ou all)." >&2
  exit 1
fi

echo "CrowdFans → testers ($FIREBASE_PROJECT / $TESTER_GROUP)"
if [[ "$TESTFLIGHT" -eq 1 ]]; then
  echo "iOS destino: TestFlight"
fi
echo "Notas: $NOTES"

status=0
case "$PLATFORM" in
  android) run_android ;;
  ios) run_ios || status=1 ;;
  web) run_web ;;
  all)
    run_android
    # Em `all` local: App Distribution ad-hoc, a menos que --testflight.
    run_ios || echo "Android enviado; iOS não."
    run_web || echo "Web não enviada."
    ;;
esac

exit "$status"
