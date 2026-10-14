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
# Variáveis opcionais: BUILD_NAME, BUILD_NUMBER, RELEASE_NOTES, JAVA_HOME, ANDROID_HOME, FLUTTER,
#   FIREBASE_TOKEN (CI token de `firebase login:ci` — preferível em SSH sem TTY).
# iOS signing (Mac, não hardcodar no git): APPLE_TEAM_ID ou DEVELOPMENT_TEAM
#   (também FLUTTER_XCODE_DEVELOPMENT_TEAM, ou Team já gravado no .pbxproj / Signing.xcconfig).
# iOS codesign over SSH: prefer one-time Keychain Access ACL / set-key-partition-list
#   on the Mac (no password on disk). Optional last resort: KEYCHAIN_PASSWORD already
#   in the session env (never write it to ~/.zprofile — see print_keychain_codesign_help).
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

# Homebrew (Apple Silicon + Intel) — mesmo problema do nvm: Terminal interativo
# tem /opt/homebrew/bin; SSH zsh -lc às vezes não. Precisa para node e `pod`.
ensure_homebrew_path() {
  for bindir in /opt/homebrew/bin /usr/local/bin; do
    if [[ -d "$bindir" ]]; then
      case ":$PATH:" in
        *":$bindir:"*) ;;
        *) export PATH="$bindir:$PATH" ;;
      esac
    fi
  done
  # gem user-install (sudo gem install cocoapods sem Homebrew)
  local gem_bin
  for gem_bin in "$HOME"/.gem/ruby/*/bin; do
    if [[ -d "$gem_bin" ]]; then
      case ":$PATH:" in
        *":$gem_bin:"*) ;;
        *) export PATH="$gem_bin:$PATH" ;;
      esac
    fi
  done
}
ensure_homebrew_path

# firebase-tools é um script com shebang `#!/usr/bin/env node`. Em SSH não-interativo
# (bash -lc) o nvm do ~/.zshrc não carrega → `command -v firebase` passa mas a
# execução falha e o erro era engolido como "Firebase CLI sem sessão".
ensure_node() {
  if command -v node >/dev/null 2>&1; then
    return 0
  fi
  for bindir in /opt/homebrew/bin /usr/local/bin; do
    if [[ -x "$bindir/node" ]]; then
      export PATH="$bindir:$PATH"
      return 0
    fi
  done
  export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
  if [[ -s "$NVM_DIR/nvm.sh" ]]; then
    # shellcheck disable=SC1090
    . "$NVM_DIR/nvm.sh"
  fi
  command -v node >/dev/null 2>&1
}

# CocoaPods no PATH (Homebrew / gem). Sem isso o Flutter reporta
# "CocoaPods not installed or not in valid state" no meio do build.
ensure_pod() {
  ensure_homebrew_path
  if command -v pod >/dev/null 2>&1; then
    return 0
  fi
  for bindir in /opt/homebrew/bin /usr/local/bin; do
    if [[ -x "$bindir/pod" ]]; then
      export PATH="$bindir:$PATH"
      return 0
    fi
  done
  return 1
}

print_cocoapods_install_hint() {
  cat >&2 <<EOF
CocoaPods não está no PATH neste shell (zsh -lc / SSH).

No Mac (uma vez):
  brew install cocoapods
  # ou: sudo gem install cocoapods
  cd $ROOT/ios && pod install

Confirme o mesmo shell que o cf usa:
  ssh guschinaglia@mac-mini.local 'zsh -lc "command -v pod && pod --version"'
EOF
}

# Garante `pod` + ios/Pods (idempotente: só roda pod install se Manifest.lock
# / Pods faltarem — seguro com Podfile.lock já versionado).
ensure_ios_pods() {
  if ! ensure_pod; then
    print_cocoapods_install_hint
    return 1
  fi
  echo "CocoaPods: $(pod --version)"
  local ios_dir="$ROOT/ios"
  if [[ ! -f "$ios_dir/Podfile" ]]; then
    echo "Podfile não encontrado em $ios_dir" >&2
    return 1
  fi
  if [[ ! -d "$ios_dir/Pods" || ! -f "$ios_dir/Pods/Manifest.lock" ]]; then
    echo "→ pod install (ios/Pods ausente ou incompleto)"
    (cd "$ios_dir" && pod install)
  fi
}

ensure_firebase_session() {
  local err_file err_text configstore
  err_file="$(mktemp "${TMPDIR:-/tmp}/cf-firebase-auth.XXXXXX")"
  if firebase projects:list --project "$FIREBASE_PROJECT" >/dev/null 2>"$err_file"; then
    rm -f "$err_file"
    return 0
  fi
  err_text="$(tr '\n' ' ' <"$err_file" | sed 's/[[:space:]]\+/ /g')"
  rm -f "$err_file"
  configstore="${XDG_CONFIG_HOME:-$HOME/.config}/configstore/firebase-tools.json"
  echo "Firebase CLI sem sessão (ou falha de auth) no projeto $FIREBASE_PROJECT." >&2
  if [[ -n "$err_text" ]]; then
    echo "  detalhe: $err_text" >&2
  fi
  if [[ -n "${FIREBASE_TOKEN:-}" ]]; then
    echo "  FIREBASE_TOKEN está setado mas a chamada falhou — regenere: npm run firebase:login:ci" >&2
  elif [[ -f "$configstore" ]]; then
    echo "  configstore existe ($configstore) mas a sessão não autenticou." >&2
    echo "  SSH sem node/nvm ou token inválido. Rode no Mac (login shell zsh):" >&2
    echo "    cd $ROOT && npm run firebase:login" >&2
    echo "  Ou gere token CI e exporte no ~/.zprofile:" >&2
    echo "    npm run firebase:login:ci   # cole o token" >&2
    echo "    echo 'export FIREBASE_TOKEN=…' >> ~/.zprofile" >&2
  else
    echo "  sem configstore em $configstore e sem FIREBASE_TOKEN." >&2
    echo "  No Mac (Terminal / zsh): cd $ROOT && npm run firebase:login" >&2
    echo "  Alternativa CI/SSH: npm run firebase:login:ci → export FIREBASE_TOKEN=…" >&2
  fi
  if ! command -v node >/dev/null 2>&1; then
    echo "  node ainda não está no PATH — nvm/Homebrew não carregou neste shell." >&2
  fi
  return 1
}

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

if ! ensure_node; then
  echo "node não está no PATH (firebase-tools precisa de node)." >&2
  echo "Em SSH, use zsh login shell (cf deploy mobile atualizado) ou:" >&2
  echo "  brew install node   # ou carregue nvm no ~/.zprofile" >&2
  exit 1
fi

if ! command -v firebase >/dev/null 2>&1; then
  echo "firebase-tools não encontrado. Rode: npm install" >&2
  exit 1
fi

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter não está no PATH. Exporte PATH=\"\$HOME/sdk/flutter/bin:\$PATH\"" >&2
  exit 1
fi

if [[ -n "${FIREBASE_TOKEN:-}" ]]; then
  echo "Firebase: auth via FIREBASE_TOKEN"
fi

if ! ensure_firebase_session; then
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

# Resolve Apple Development Team id for non-interactive archive (SSH / cf deploy).
# Prefer env on the Mac (or forwarded by cf); never invent a team id.
resolve_ios_development_team() {
  local team pbx xcconfig
  team="${APPLE_TEAM_ID:-${DEVELOPMENT_TEAM:-${FLUTTER_XCODE_DEVELOPMENT_TEAM:-}}}"
  team="$(printf '%s' "$team" | tr -d '[:space:]')"
  if [[ -n "$team" ]]; then
    printf '%s\n' "$team"
    return 0
  fi
  pbx="$ROOT/ios/Runner.xcodeproj/project.pbxproj"
  if [[ -f "$pbx" ]]; then
    team="$(
      grep -E 'DEVELOPMENT_TEAM = [A-Z0-9]+;' "$pbx" 2>/dev/null \
        | head -1 \
        | sed -E 's/.*DEVELOPMENT_TEAM = ([A-Z0-9]+);.*/\1/' \
        || true
    )"
    team="$(printf '%s' "$team" | tr -d '[:space:]')"
    if [[ -n "$team" ]]; then
      printf '%s\n' "$team"
      return 0
    fi
  fi
  xcconfig="$ROOT/ios/Flutter/Signing.xcconfig"
  if [[ -f "$xcconfig" ]]; then
    team="$(
      grep -E '^[[:space:]]*DEVELOPMENT_TEAM[[:space:]]*=' "$xcconfig" 2>/dev/null \
        | grep -v '^[[:space:]]*//' \
        | head -1 \
        | sed -E 's/^[[:space:]]*DEVELOPMENT_TEAM[[:space:]]*=[[:space:]]*//' \
        | tr -d '[:space:];' \
        || true
    )"
    if [[ -n "$team" && "$team" != '$(DEVELOPMENT_TEAM)' ]]; then
      printf '%s\n' "$team"
      return 0
    fi
  fi
  return 1
}

print_ios_signing_help() {
  cat >&2 <<EOF
iOS signing: falta Development Team e/ou identidade Apple no Keychain.

Archive remoto (cf deploy mobile / SSH) precisa de:
  1) Identidade "Apple Development" ou "Apple Distribution" no Keychain
  2) Team id via env (preferido) ou Xcode / xcconfig

No Mac (uma vez):
  open $ROOT/ios/Runner.xcworkspace
  → Runner target → Signing & Capabilities
  → login Apple ID (Xcode → Settings → Accounts)
  → Team = Crowdfans (ou sua conta)
  → Automatically manage signing = ON

Ou grave o Team id só neste Mac (não commitar):
  echo 'export APPLE_TEAM_ID=GS955J2P93' >> ~/.zprofile   # Crowdfans
  # aliases aceitos: DEVELOPMENT_TEAM / FLUTTER_XCODE_DEVELOPMENT_TEAM

Team id Crowdfans: GS955J2P93
  (Xcode → Settings → Accounts → Team → Team ID)

Conferir neste shell (mesmo zsh -lc do cf):
  security find-identity -v -p codesigning
  echo "APPLE_TEAM_ID=\${APPLE_TEAM_ID:-\${DEVELOPMENT_TEAM:-unset}}"
EOF
}

print_keychain_codesign_help() {
  cat >&2 <<EOF
iOS codesign: errSecInternalComponent (private key ACL / locked keychain over SSH).

SSH não-interativo não abre UI para autorizar a chave.
Team Crowdfans: GS955J2P93 · identity tipicamente 7248BFB5…

No Mac — happy path (uma vez, interativo; NÃO grave senha em arquivo):

  # Opção A — Keychain Access (recomendado):
  # open -a "Keychain Access"
  # → login → Keys → chave privada do Apple Distribution/Development
  # → Get Info → Access Control
  # → Allow: codesign, Xcode, xcodebuild  (ou "Allow all applications" só nesta chave)
  # Confirme com a senha do login keychain na UI — senha NÃO vai para disco via script.

  # Opção B — partition ACL one-shot (Terminal local no Mac; senha só na memória):
  read -s -p 'login keychain password: ' KC_PASS; echo
  security set-key-partition-list -S apple-tool:,apple:,codesign: -s \\
    -k "\$KC_PASS" "\$HOME/Library/Keychains/login.keychain-db"
  unset KC_PASS
  # Depois disso, SSH codesign costuma funcionar sem KEYCHAIN_PASSWORD.

  # Opção C (avançado): keychain dedicado só com identidades de signing
  # (não usar a senha do login keychain em env permanente).

Last resort (desencorajado): KEYCHAIN_PASSWORD / MAC_KEYCHAIN_PASSWORD já na
sessão atual (export manual no Terminal). NUNCA echo >> ~/.zprofile / git.

Retry: cf deploy mobile --platform ios
EOF
}

resolve_login_keychain() {
  if [[ -f "$HOME/Library/Keychains/login.keychain-db" ]]; then
    printf '%s\n' "$HOME/Library/Keychains/login.keychain-db"
  elif [[ -f "$HOME/Library/Keychains/login.keychain" ]]; then
    printf '%s\n' "$HOME/Library/Keychains/login.keychain"
  else
    printf '%s\n' "$HOME/Library/Keychains/login.keychain-db"
  fi
}

# Optional session unlock when KEYCHAIN_PASSWORD is already in the environment.
# Happy path is one-time Keychain Access ACL / partition-list (no password on disk).
# Never write the password to ~/.zprofile from this script.
maybe_unlock_ios_keychain() {
  local pass kc
  pass="${KEYCHAIN_PASSWORD:-${MAC_KEYCHAIN_PASSWORD:-}}"
  kc="$(resolve_login_keychain)"
  if [[ -z "$pass" ]]; then
    echo "→ iOS keychain: sem KEYCHAIN_PASSWORD na sessão — OK se ACL/partition já permite codesign"
    echo "  (errSecInternalComponent → Keychain Access Allow codesign, ou partition-list one-shot)"
    return 0
  fi
  echo "→ KEYCHAIN_PASSWORD na sessão (last resort) — unlock + partition para este archive"
  if ! security unlock-keychain -p "$pass" "$kc"; then
    echo "Falha ao unlock-keychain ($kc). Prefira Keychain Access ACL; senha de sessão inválida?" >&2
    print_keychain_codesign_help
    return 1
  fi
  if ! security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k "$pass" "$kc" >/dev/null 2>&1; then
    echo "Aviso: set-key-partition-list falhou — rode Opção A/B (Keychain Access / one-shot)." >&2
  else
    echo "→ key-partition-list: apple-tool:,apple:,codesign: OK (sessão)"
  fi
  return 0
}

# Fail early before flutter build ipa — clear Mac steps, no archive attempt.
preflight_ios_signing() {
  local team
  if ! has_ios_signing; then
    echo "iOS preflight: nenhuma identidade Apple Development/Distribution no Keychain." >&2
    print_ios_signing_help
    return 1
  fi
  if ! team="$(resolve_ios_development_team)"; then
    echo "iOS preflight: DEVELOPMENT_TEAM / APPLE_TEAM_ID não definido (pbxproj sem Team)." >&2
    print_ios_signing_help
    return 1
  fi
  export DEVELOPMENT_TEAM="$team"
  export APPLE_TEAM_ID="${APPLE_TEAM_ID:-$team}"
  export FLUTTER_XCODE_DEVELOPMENT_TEAM="$team"
  echo "→ iOS Development Team: $team (automatic signing)"
  return 0
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
  if ! ensure_ios_pods; then
    return 1
  fi
  preflight_ios_signing || return 1
  maybe_unlock_ios_keychain || return 1
  local export_method='ad-hoc'
  if [[ "$TESTFLIGHT" -eq 1 ]]; then
    export_method='app-store'
  fi
  echo "→ IPA $build_name ($build_number) export-method=$export_method team=$DEVELOPMENT_TEAM"
  # NÃO passar DEVELOPMENT_TEAM=… / CODE_SIGN_STYLE=… como args posicionais
  # (Flutter trata KEY=VAL após -- como "target file" → "Target file … not found").
  # Team chega ao xcodebuild via env (export em preflight_ios_signing):
  #   DEVELOPMENT_TEAM / FLUTTER_XCODE_DEVELOPMENT_TEAM / APPLE_TEAM_ID
  # e/ou ios/Flutter/Signing.xcconfig (DEVELOPMENT_TEAM = …).
  local log ec
  log="$(mktemp "${TMPDIR:-/tmp}/cf-ios-ipa.XXXXXX")"
  set +e
  flutter build ipa --release --export-method "$export_method" \
    --build-name="$build_name" \
    --build-number="$build_number" 2>&1 | tee "$log"
  ec=${PIPESTATUS[0]}
  set -e
  if [[ "$ec" -ne 0 ]]; then
    if grep -qE 'errSecInternalComponent|CSSMERR_CSP_DISABLED|Failed to codesign' "$log"; then
      echo >&2
      print_keychain_codesign_help
    elif grep -qE 'Encountered error while archiving for device|archiving for device' "$log"; then
      echo >&2
      echo "Archive iOS falhou. Se o log acima tem errSecInternalComponent / Failed to codesign:" >&2
      print_keychain_codesign_help
    fi
    rm -f "$log"
    return "$ec"
  fi
  rm -f "$log"
  return 0
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

# Em `all`: continua após um fail e resume ok|fail (não engole exit).
status=0
ALL_RESULTS=()

record_all() {
  local name="$1"
  local ec="$2"
  local hint="${3:-}"
  if [[ "$ec" -eq 0 ]]; then
    ALL_RESULTS+=("${name}|ok|")
  else
    ALL_RESULTS+=("${name}|fail|${hint}")
    status=1
  fi
}

case "$PLATFORM" in
  android) run_android ;;
  ios) run_ios || status=1 ;;
  web) run_web ;;
  all)
    set +e
    run_android
    record_all android $? "veja log Android acima"
    # Em `all` local: App Distribution ad-hoc, a menos que --testflight.
    run_ios
    record_all ios $? "signing/Keychain ou upload — veja PENDENCIA.md / ASC"
    run_web
    record_all web $? "veja log Web/Hosting acima"
    set -e
    echo
    echo "======== platform summary ========"
    echo "CF_PLATFORM_SUMMARY_BEGIN"
    for entry in "${ALL_RESULTS[@]}"; do
      name="${entry%%|*}"
      rest="${entry#*|}"
      result="${rest%%|*}"
      detail="${rest#*|}"
      if [[ "$result" == "ok" ]]; then
        echo "${name}: ok"
        echo "[ok]   ${name}"
      else
        echo "${name}: fail | ${detail}"
        echo "[fail] ${name} — ${detail}"
      fi
    done
    echo "CF_PLATFORM_SUMMARY_END"
    echo "======== end platform summary ========"
    ;;
esac

exit "$status"
