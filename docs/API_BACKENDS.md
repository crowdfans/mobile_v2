# API backends — GCP vs DigitalOcean

Linha **GCP** (`release/0.2`): default `APP_FLAVOR=gcp` / `API_MODE=gcp` → Cloud Run.  
Linha **DO** (`prod`): permanece `0.1.x` + server-prod DigitalOcean — **não** misturar no mesmo PR.

## Flavors

| Flavor | Android `--flavor` | Config | Base URL |
|--------|--------------------|--------|----------|
| `gcp` | `gcp` | `config/gcp.json` / `.env.gcp` | Cloud Run staging |
| `digitalocean` | `digitalocean` | `config/digitalocean.json` | DO server-prod |
| `local` | `gcp` + mode local | `config/local.json` | `localhost:8080` |

```bash
./scripts/run_backend.sh gcp
./scripts/run_backend.sh digitalocean
./scripts/run_backend.sh local

# ou:
flutter run --flavor gcp --dart-define-from-file=config/gcp.json
```

iOS: use `--dart-define-from-file=config/….json` (schemes nativos de flavor ainda não espelhados). Android exige `--flavor` após os productFlavors.

## Env

- `API_GCP_BASE_URL` / `API_GCP_STAGING_BASE_URL` / `API_GCP_PROD_BASE_URL`
- `API_DIGITALOCEAN_BASE_URL` (só flavor DO)
- `API_LOCAL_BASE_URL`
- `API_BASE_URL` força qualquer modo
- Hosts mortos (`crowdfans-app-dev*`, `crowdfans-app-prod`) → fallback do modo ativo (nunca esses hosts)

Placeholders Cloud Run são provisórios até o deploy real (CF-286+). Atualizar JSON/env com a URL `.run.app` retornada pelo `gcloud run services describe`.

## Firebase

Options + `google-services` / plist **por flavor**, stubs sem segredos.  
Detalhe: [FIREBASE_FLAVORS.md](./FIREBASE_FLAVORS.md).

## Patrol / GRE stubs (gcp)

Unit + Patrol smoke contra Cloud Run **placeholder** (pré-deploy).  
Detalhe: [PATROL_GCP_FLAVOR.md](./PATROL_GCP_FLAVOR.md).

## App Distribution (gcp)

Builds flavor gcp → Firebase App Distribution.  
Detalhe: [APP_DISTRIBUTION_GCP.md](./APP_DISTRIBUTION_GCP.md).

## Mídia GCS (CF-339)

Upload/preview: shapes `storage.googleapis.com` / signed `X-Goog-*` (sem Spaces).  
Detalhe: [MEDIA_GCS.md](./MEDIA_GCS.md).

## Cutover flags / Remote Config (CF-359)

Kill-switch e overrides de API/mídia em dual-run: [REMOTE_CONFIG_CUTOVER.md](./REMOTE_CONFIG_CUTOVER.md).  
`cf_cutover_force_digitalocean=true` → rollback para DO server-prod.

## Versão

`pubspec` nesta linha: `0.2.0+N`. Ver [VERSIONING.md](./VERSIONING.md).
