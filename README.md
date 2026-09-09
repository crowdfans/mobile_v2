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
| CF-130 | `e2e_artist_edit_delete_post_test.dart` | artista |

Helpers: `integration_test/helpers/e2e_env.dart`, `e2e_auth.dart`.

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
npm run distribute:ios      # IPA ad-hoc, se o signing Apple existir
npm run distribute:web      # Flutter web no Hosting (canal testers)
npm run distribute:all
```

Web **não** entra no App Distribution (só APK/IPA). O script sobe um [preview channel](https://firebase.google.com/docs/hosting/manage-preview-channels) `testers` em `crowdfans-prod` (expira em 14 dias) e imprime o URL. No console: Authentication → Authorized domains → cole esse host. OTP no browser ainda precisa do reCAPTCHA (`PENDENCIA.md`).

No Cursor: **Terminal → Run Task… → App Distribution: Android** (ou Web). Notas padrão = último commit; override com `./scripts/distribute.sh android --notes "…"`.

## Estrutura

Espelha o mobile Expo:

- `lib/constants/pages.dart` — rotas (`Pages.*`)
- `lib/api/api_urls.dart` — endpoints (`ApiUrls.*`)
- `lib/services/` — facade (`AuthService`, `HttpService`, `ProfileService`)
- `lib/screens/` — telas (estado da tela no próprio arquivo)

## Migração

Ver `MIGRATION.md`. O Expo em `../mobile` continua sendo a referência de comportamento até cada tela ser marcada como feita.
