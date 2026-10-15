# CrowdFans mobile_v2 (Flutter)

App Flutter CrowdFans (`mobile_v2`).

## Rodar

```bash
export PATH="$HOME/sdk/flutter/bin:$PATH"   # se o Flutter não estiver no PATH
cp .env.example .env                        # opcional; o app já carrega .env.example
flutter pub get
flutter run
```

API padrão (Cloud Run): `https://crowdfans-server-peefddw6nq-rj.a.run.app`. Para o Go local:

```
API_MODE=local
API_LOCAL_BASE_URL=http://localhost:8080
```

Login nativo usa o Firebase **`crowdfans-prod`**.

## Patrol (QA E2E)

Setup nativo Android/iOS (CF-123). CLI:

```bash
dart pub global activate patrol_cli
export PATH="$HOME/sdk/flutter/bin:$HOME/.pub-cache/bin:$PATH"
patrol doctor
```

Smoke local (emulador/simulador ligado):

```bash
patrol test -t integration_test/smoke_test.dart
patrol test -t integration_test/superfan_onboarding_login_test.dart
```

### E2E autenticados (CF-128 / CF-129 / CF-130)

Fluxos reais contra a API de produção no Cloud Run
(`https://crowdfans-server-peefddw6nq-rj.a.run.app`). Sem credenciais o
teste fica `skip` com mensagem clara — **não** finge verde.

1. Copie o exemplo e preencha contas de teste (nunca committe):

```bash
cp .env.e2e.example .env.e2e
```

2. Injete as variáveis no Patrol (`String.fromEnvironment`). Opções:

```bash
# Opção A — --dart-define explícito
patrol test -t integration_test/e2e_artist_post_fan_comment_test.dart \
  --dart-define=E2E_ARTIST_EMAIL='...' \
  --dart-define=E2E_ARTIST_PASSWORD='...' \
  --dart-define=E2E_FAN_EMAIL='...' \
  --dart-define=E2E_FAN_PASSWORD='...'

patrol test -t integration_test/e2e_superfan_vote_club_logout_test.dart \
  --dart-define=E2E_FAN_EMAIL='...' \
  --dart-define=E2E_FAN_PASSWORD='...' \
  --dart-define=E2E_ARTIST_UID='...'   # opcional, comunidade direta

patrol test -t integration_test/e2e_artist_edit_delete_post_test.dart \
  --dart-define=E2E_ARTIST_EMAIL='...' \
  --dart-define=E2E_ARTIST_PASSWORD='...'

# Opção B — .patrol.env na raiz (gitignored; Patrol carrega automaticamente)
# E2E_FAN_EMAIL=...
# E2E_FAN_PASSWORD=...
```

Opcionais: `E2E_ARTIST_UID`, `E2E_FAN_UID`, `E2E_FAN_HANDLE`, `E2E_SEED_POST_ID`
.

| Ticket | Arquivo | Credenciais |
|---|---|---|
| CF-128 | `e2e_artist_post_fan_comment_test.dart` | artista + fã |
| CF-129 | `e2e_superfan_vote_club_logout_test.dart` | fã (+ `E2E_ARTIST_UID` recomendado) |
| CF-130 | `e2e_artist_edit_delete_post_test.dart` | artista | green: editar+apagar via `create-menu-my-posts`; red: login inválido / cancelar delete; edge: texto 280 |

Helpers: `integration_test/helpers/e2e_env.dart`, `e2e_auth.dart`.

**CF-128 green / red / edge (obrigatório):**

| Grupo | Patrol (`e2e_artist_post_fan_comment_test.dart`) | Widget (`test/components/cf128_artist_post_fan_comment_test.dart`) |
|---|---|---|
| GREEN | artista posta → superfã comenta → texto visível | `comment-submit` com rascunho; `post-comments`; publish com texto |
| RED | senha inválida fica no login; composer vazio sem `comment-submit` | draft vazio / publish desabilitado |
| EDGE | comentário longo visível | teclado `viewInsets`; zero comentários; limite 280 |

Widget suite: `flutter test test/components/cf128_artist_post_fan_comment_test.dart`.

### Firebase Test Lab (CF-125 / CF-126)

Android **pronto**: APIs FTL no `crowdfans-prod` + `scripts/ftl_android.sh` (job smoke Passed).
Guia: [`docs/FIREBASE_TEST_LAB.md`](docs/FIREBASE_TEST_LAB.md). iOS (CF-127) ainda bloqueado em signing (`PENDENCIA.md`).

```bash
./scripts/ftl_android.sh --dry-run   # valida models list + imprime plano
./scripts/ftl_android.sh             # patrol build + submit FTL (smoke)
npm run ftl:android
```
## App Distribution

Grupo `flutter-testers` no projeto `crowdfans-prod`. Primeira vez no CLI: `npm install` e `npm run firebase:login` (Terminal no Mac — shell de login zsh).

Para `cf deploy mobile` via SSH (sem TTY), o Mac precisa de **node no PATH** (nvm/Homebrew no `~/.zprofile`) e sessão Firebase. Preferências:

1. `npm run firebase:login` no Mac (grava `~/.config/configstore/firebase-tools.json`), **ou**
2. `npm run firebase:login:ci` → `export FIREBASE_TOKEN=…` no `~/.zprofile` (ou `cf` encaminha se a env existir no caller).

```bash
npm run distribute          # gera o APK e envia (o atalho do dia a dia)
npm run distribute:ios      # IPA ad-hoc → App Distribution (se signing existir)
npm run distribute:ios:testflight  # IPA app-store → TestFlight (ASC no Mac)
npm run distribute:web      # Flutter web no Hosting (canal testers)
npm run distribute:all
```

Web **não** entra no App Distribution (só APK/IPA). O script sobe um [preview channel](https://firebase.google.com/docs/hosting/manage-preview-channels) `testers` em `crowdfans-prod` (expira em 14 dias) e imprime o URL. No console: Authentication → Authorized domains → cole esse host. OTP no browser ainda precisa do reCAPTCHA (`PENDENCIA.md`).

No Cursor: **Terminal → Run Task… → App Distribution: Android** (ou Web). Notas padrão = último commit; override com `./scripts/distribute.sh android --notes "…"`.

## Remote deploy (Mac always-on)

**Product UX:** from any machine, only:

```bash
cf deploy mobile
```

The `cf` CLI is a thin SSH trigger. The caller never needs Flutter, Xcode, or the Android SDK. The Mac under `/Users/guschinaglia/Developer/CrowdFans/mobile_v2` does `git fetch` / `checkout prod` / `pull --ff-only`, then the full build + upload.

```bash
# any machine with cf + SSH key (no Flutter here)
cf deploy mobile --dry-run              # resolved host + remote command plan
cf deploy mobile                        # firebase = Android App Dist + Web Hosting
cf deploy mobile --platform android     # optional filter
cf deploy mobile --platform ios         # opt-in remote TestFlight (or do iOS by hand on Mac)
```

On the Mac, SSH runs `scripts/remote_deploy.sh` (mkdir lock → git ff-only → `distribute.sh`). You can also invoke that script directly on the Mac for debugging:

```bash
./scripts/remote_deploy.sh --dry-run
./scripts/remote_deploy.sh --platform firebase
./scripts/remote_deploy.sh --platform ios
npm run remote-deploy:dry
```

Defaults locked: host `mac-mini.local`, user `guschinaglia`, path
`/Users/guschinaglia/Developer/CrowdFans/mobile_v2`, ref `prod`.
**Happy path:** Android → App Distribution `flutter-testers`; web → Hosting `testers`.
**iOS/TestFlight:** opt-in (`--platform ios`) or manual on the Mac — not the default remote path.

### Setup Mac (Gustavo) — once

1. Checkout `mobile_v2` em `/Users/guschinaglia/Developer/CrowdFans/mobile_v2`, branch `prod`.
2. Flutter, Xcode, Android SDK, `npm install`, `npm run firebase:login` (no Terminal zsh do Mac).
3. **CocoaPods** (só se for usar iOS remoto / TestFlight — mesmo shell `zsh -lc` que o `cf` usa; **não** necessário para `cf deploy mobile` default/firebase):
   ```bash
   brew install cocoapods
   # ou: sudo gem install cocoapods
   cd /Users/guschinaglia/Developer/CrowdFans/mobile_v2/ios && pod install
   ```
   Confirme no shell de login não-interativo:
   ```bash
   ssh guschinaglia@mac-mini.local 'zsh -lc "command -v pod && pod --version"'
   ```
   Se `pod` só existir no Terminal interativo: garanta `/opt/homebrew/bin` no `~/.zprofile` (os scripts `distribute.sh` / `remote_deploy.sh` também prependem Homebrew/gem no PATH).
4. Confirme que **node** e Firebase funcionam num shell de login não-interativo (o mesmo que o `cf` usa):
   ```bash
   ssh guschinaglia@mac-mini.local 'zsh -lc "cd /Users/guschinaglia/Developer/CrowdFans/mobile_v2 && command -v node && npx firebase projects:list --project crowdfans-prod | head"'
   ```
   Se `node` faltar: coloque nvm/Homebrew no `~/.zprofile`, ou `brew install node`.
   Alternativa: `npm run firebase:login:ci` → `echo 'export FIREBASE_TOKEN=…' >> ~/.zprofile`.
5. **iOS Development Team** (só para archive remoto / TestFlight opt-in; ignore no happy path Firebase):
   - Abra `ios/Runner.xcworkspace` no Xcode → target **Runner** → **Signing & Capabilities**.
   - Login Apple ID (Xcode → Settings → Accounts) → selecione o **Team** Crowdfans → **Automatically manage signing**.
   - **Ou** exporte só neste Mac (zsh login — `cf` usa `zsh -lc`; **não** commitar):
     ```bash
     echo 'export APPLE_TEAM_ID=GS955J2P93' >> ~/.zprofile   # Crowdfans Team ID
     # aliases: DEVELOPMENT_TEAM / FLUTTER_XCODE_DEVELOPMENT_TEAM
     ```
   - Confira: `security find-identity -v -p codesigning` (precisa Apple Development ou Distribution).
6. **iOS codesign over SSH** (se archive falhar com `errSecInternalComponent`):
   - Causa clássica: SSH sem TTY → `codesign` não consegue autorizar a chave privada.
   - **Happy path (uma vez, no Mac — sem gravar senha em arquivo):**
     1. Keychain Access → login → Keys → chave privada Apple Distribution/Development → Get Info → Access Control → permitir `codesign` / Xcode (ou Allow all **só nesta chave**), **ou**
     2. Terminal local (prompt interativo — senha só na memória, **não** em `~/.zprofile`):
        ```bash
        read -s -p 'login keychain password: ' KC_PASS; echo
        security set-key-partition-list -S apple-tool:,apple:,codesign: -s \
          -k "$KC_PASS" "$HOME/Library/Keychains/login.keychain-db"
        unset KC_PASS
        ```
   - Depois da ACL/partition, `cf deploy mobile --platform ios` costuma funcionar sem senha na sessão.
   - **Não** coloque a senha do login keychain em `~/.zprofile`. `KEYCHAIN_PASSWORD` na sessão é last resort apenas.
7. Credenciais ASC para upload TestFlight (env no **zsh** login shell do Mac — **não** no git):
   - `ASC_API_KEY_ID` + `ASC_API_ISSUER_ID` + `ASC_API_KEY_PATH` (`.p8`), **ou**
   - `ASC_USERNAME` + `ASC_APP_SPECIFIC_PASSWORD`
8. Em cada máquina que dispara deploy: chave SSH (`~/.ssh/cf_mobile_deploy`) → `guschinaglia@mac-mini.local`.
9. mDNS/DNS resolve `mac-mini.local` na LAN; TCP `:22` responde.

Sem Team id / identidade Apple, `distribute.sh ios --testflight` falha no **preflight** (antes do archive) com os passos acima. Sem ASC no Mac, o IPA ainda pode ser gerado em `build/ios/ipa/` (Transporter manual). `cf deploy mobile --dry-run` no caller só imprime o plano remoto — sem build local.

## Estrutura

Espelha o fluxo mobile:

- `lib/constants/pages.dart` — rotas (`Pages.*`)
- `lib/api/api_urls.dart` — endpoints (`ApiUrls.*`)
- `lib/services/` — facade (`AuthService`, `HttpService`, `ProfileService`)
- `lib/screens/` — telas (estado da tela no próprio arquivo)

## Migração

Ver `MIGRATION.md`. Layout: prints YouTrack / `Downloads/Screens`.
