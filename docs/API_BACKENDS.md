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

## Versão

`pubspec` nesta linha: `0.2.0+N`. Ver [VERSIONING.md](./VERSIONING.md).
