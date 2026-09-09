# Firebase Test Lab — CrowdFans (`crowdfans-prod`)

Infra e wiring Android para Patrol no Firebase Test Lab (CF-125 / CF-126).
iOS (CF-127) continua bloqueado em signing Apple — ver `PENDENCIA.md`.

## Status (2026-09-09)

| Item | Estado |
|---|---|
| `gcloud auth` (user) | OK — `crowdfans@gmail.com` |
| `testing.googleapis.com` | Habilitada em `crowdfans-prod` |
| `toolresults.googleapis.com` | Habilitada em `crowdfans-prod` |
| `gcloud firebase test android models list` | OK |
| Script Android | `scripts/ftl_android.sh` |
| Job FTL smoke | **Passed** — `MediumPhone.arm-34` (1 test) |
| Console matrix | [histories/…/matrices/8325692657276862944](https://console.firebase.google.com/project/crowdfans-prod/testlab/histories/bh.a2f5d65cf7c8b570/matrices/8325692657276862944) |
| iOS FTL | Bloqueado (signing / App Distribution iOS) |

## Pré-requisitos

```bash
# Flutter + Patrol
export PATH="$HOME/sdk/flutter/bin:$HOME/.pub-cache/bin:$PATH"
dart pub global activate patrol_cli

# gcloud (user)
gcloud auth login
gcloud config set project crowdfans-prod

# Prova rápida de API
gcloud firebase test android models list --project crowdfans-prod
```

### Service account (CI / máquina compartilhada)

Não inventar nem commititar JSON de SA. No console GCP (`crowdfans-prod`):

1. IAM → Service Accounts → Create (`ftl-runner@crowdfans-prod.iam.gserviceaccount.com` ou similar).
2. Papéis mínimos:
   - **Firebase Test Lab Admin** (`roles/cloudtestservice.testAdmin`)
   - Se o bucket de resultados for restrito: **Storage Object Admin** no bucket FTL.
3. Criar chave JSON **só localmente** (ou Secret Manager / GitHub Actions secret).
4. Usar:

```bash
export GOOGLE_APPLICATION_CREDENTIALS=/caminho/secreto/ftl-sa.json
gcloud auth activate-service-account --key-file="$GOOGLE_APPLICATION_CREDENTIALS"
./scripts/ftl_android.sh
```

User credentials (`gcloud auth login`) bastam para rodar o script na máquina do time.

## Android — uso

```bash
# Só imprime o plano + valida models list
./scripts/ftl_android.sh --dry-run

# Build Patrol + submit FTL (smoke padrão)
./scripts/ftl_android.sh

# Outro target
./scripts/ftl_android.sh --target integration_test/superfan_onboarding_login_test.dart

# Reenviar APKs já gerados
./scripts/ftl_android.sh --skip-build
```

Atalhos npm:

```bash
npm run ftl:android:dry
npm run ftl:android
```

Env úteis: `PATROL_TEST`, `FTL_DEVICE_MODEL` (default `MediumPhone.arm`),
`FTL_DEVICE_VERSION` (default `34`), `FIREBASE_PROJECT`, `FTL_TIMEOUT`.

APKs esperados (Patrol):

- `build/app/outputs/apk/debug/app-debug.apk`
- `build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk`

Console: [Firebase Test Lab](https://console.firebase.google.com/project/crowdfans-prod/testlab/histories).

## iOS (CF-127)

Ainda **não** há script FTL iOS. Motivo: signing Apple / IPA Ad Hoc pendente
(`PENDENCIA.md` §1 — 0 certificados no Xcode). Depois do signing:

1. `patrol build ios --target integration_test/smoke_test.dart`
2. `gcloud firebase test ios run …` com o `.zip` XCTest gerado pelo Patrol.

## Billing

FTL consome cota/billing do projeto Firebase/GCP. Preferir device virtual
`MediumPhone.arm` + smoke curto para validação de infra.
