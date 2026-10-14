# API backends — GCP

Linha operacional (`release/0.2`): default `APP_FLAVOR=gcp` / `API_MODE=gcp` → Cloud Run.  
Sem DigitalOcean / App Platform operacional ([CF-354](https://crowd-fans.youtrack.cloud/issue/CF-354)).

## Hosts canônicos (CF-361)

| Linha | API |
|-------|-----|
| **GCP** (`release/0.2`) | `https://crowdfans-server-peefddw6nq-rj.a.run.app` · financial `https://crowdfans-financial-peefddw6nq-rj.a.run.app` |
| **Local** | `API_MODE=local` → `http://localhost:8080` |

**Proibido:** `crowdfans-app-dev*`, `crowdfans-app-prod.ondigitalocean.app`, `*.ondigitalocean.app` como alvo de load/seed/mobile.

Constantes: `lib/services/api_config.dart`. Override: `API_BASE_URL` / `--dart-define=API_BASE_URL=…`.

Deep links: `lib/constants/deep_link_hosts.dart` (`crowdfans.app`, `staging.crowdfans.app` placeholder).

## Flavors

| Flavor | Android `--flavor` | Config | Base URL |
|--------|--------------------|--------|----------|
| `gcp` | `gcp` | `config/gcp.json` / `.env.gcp` | Cloud Run |
| `local` | `gcp` + mode local | `config/local.json` | `localhost:8080` |

Flavor `digitalocean` permanece no tree só como arquivo de cutover (kill-switch Remote Config) — **não** é happy path nem CI.

```bash
./scripts/run_backend.sh gcp
./scripts/run_backend.sh local

# ou:
flutter run --flavor gcp --dart-define-from-file=config/gcp.json
```

iOS: use `--dart-define-from-file=config/….json` (schemes nativos de flavor ainda não espelhados). Android exige `--flavor` após os productFlavors.

## Env

- `API_GCP_BASE_URL` / `API_GCP_STAGING_BASE_URL` / `API_GCP_PROD_BASE_URL`
- `API_LOCAL_BASE_URL`
- `API_BASE_URL` força qualquer modo
- Hosts mortos (`crowdfans-app-dev*`, `crowdfans-app-prod`, `*.ondigitalocean.app`) → recusar / nunca default

## Firebase

Options + `google-services` / plist **por flavor**, stubs sem segredos.  
Detalhe: [FIREBASE_FLAVORS.md](./FIREBASE_FLAVORS.md).

## App Distribution (gcp)

Builds flavor gcp → Firebase App Distribution.  
Detalhe: [APP_DISTRIBUTION_GCP.md](./APP_DISTRIBUTION_GCP.md).

## Mídia GCS (CF-339)

Upload/preview: shapes `storage.googleapis.com` / signed `X-Goog-*` (sem Spaces).  
Detalhe: [MEDIA_GCS.md](./MEDIA_GCS.md).

## Cutover flags / Remote Config (CF-359)

Kill-switch e overrides de API/mídia: [REMOTE_CONFIG_CUTOVER.md](./REMOTE_CONFIG_CUTOVER.md).  
Não reativar App Platform / workflows DO como caminho de CI.

## Versão

`pubspec` nesta linha: `0.2.0+N`. Ver [VERSIONING.md](./VERSIONING.md).
