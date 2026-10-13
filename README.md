# CrowdFans mobile_v2 (Flutter)

Reescrita do app Expo em [`crowdfans/mobile`](https://github.com/crowdfans/mobile) para Flutter.

## Rodar

```bash
export PATH="$HOME/sdk/flutter/bin:$PATH"   # se o Flutter não estiver no PATH
cp .env.example .env                        # opcional; o app já carrega .env.example
flutter pub get
flutter run
```

API padrão: `https://crowdfans-server-prod-h9qb6.ondigitalocean.app`. Para o Go local:

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

Fluxos reais contra a API de produção
(`https://crowdfans-server-prod-h9qb6.ondigitalocean.app`). Sem credenciais o
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
(espelho do Expo `../mobile/.env.e2e.example`).

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

Grupo `flutter-testers` no projeto `crowdfans-prod`. Primeira vez no CLI: `npm install` e `npm run firebase:login`.

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
cf deploy mobile                        # all = android + ios TestFlight + web
cf deploy mobile --platform android     # optional filter
```

On the Mac, SSH runs `scripts/remote_deploy.sh` (mkdir lock → git ff-only → `distribute.sh`). You can also invoke that script directly on the Mac for debugging:

```bash
./scripts/remote_deploy.sh --dry-run
./scripts/remote_deploy.sh --platform ios
npm run remote-deploy:dry
```

Defaults locked: host `mac-mini.local`, user `guschinaglia`, path
`/Users/guschinaglia/Developer/CrowdFans/mobile_v2`, ref `prod`.
iOS remoto → **TestFlight**; Android → App Distribution `flutter-testers`; web → Hosting `testers`.

### Setup Mac (Gustavo) — once

1. Checkout `mobile_v2` em `/Users/guschinaglia/Developer/CrowdFans/mobile_v2`, branch `prod`.
2. Flutter, Xcode, Android SDK, `npm install`, `npm run firebase:login`.
3. Signing Apple Distribution no Keychain (IPA `app-store`).
4. Credenciais ASC para upload TestFlight (env no login shell do Mac — `cf` SSHs with `bash -lc`; **não** no git):
   - `ASC_API_KEY_ID` + `ASC_API_ISSUER_ID` + `ASC_API_KEY_PATH` (`.p8`), **ou**
   - `ASC_USERNAME` + `ASC_APP_SPECIFIC_PASSWORD`
5. Em cada máquina que dispara deploy: chave SSH (`~/.ssh/cf_mobile_deploy`) → `guschinaglia@mac-mini.local`.
6. mDNS/DNS resolve `mac-mini.local` na LAN; TCP `:22` responde.

Sem ASC no Mac, o IPA ainda é gerado em `build/ios/ipa/` (Transporter manual). `cf deploy mobile --dry-run` no caller só imprime o plano remoto — sem build local.

## Estrutura

Espelha o mobile Expo:

- `lib/constants/pages.dart` — rotas (`Pages.*`)
- `lib/api/api_urls.dart` — endpoints (`ApiUrls.*`)
- `lib/services/` — facade (`AuthService`, `HttpService`, `ProfileService`)
- `lib/screens/` — telas (estado da tela no próprio arquivo)

## Migração

Ver `MIGRATION.md`. O Expo em `../mobile` continua sendo a referência de comportamento até cada tela ser marcada como feita.
