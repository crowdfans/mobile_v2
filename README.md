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

E2E autenticados (CF-128/129/130) estão **skip** até existirem `E2E_ARTIST_*` / `E2E_FAN_*`.

Firebase Test Lab (CF-125/126/127) está **adiado** — ver `docs/YOUTRACK_BACKLOG.md` (API/`gcloud` + SA no `crowdfans-prod` ainda não prontos).

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
