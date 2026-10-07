# GCP staging — API base URL + deep links (placeholders)

**Branch:** `release/0.2` · **Task:** [CF-357](https://crowd-fans.youtrack.cloud/issue/CF-357) · **Épica:** [CF-356](https://crowd-fans.youtrack.cloud/issue/CF-356)  
**SoT Git:** Project `docs/gcp-git-flow.md`

## Por quê placeholders

[CF-286](https://crowd-fans.youtrack.cloud/issue/CF-286) bloqueia project/billing GCP → sem Cloud Run URL real ainda. Este PR só **fio** config no app para staging, sem trocar o default DO vivo.

## API

| `API_MODE` | Base URL |
|------------|----------|
| `digitalocean` (default) | `API_DIGITALOCEAN_BASE_URL` → server-prod DO |
| `local` | `API_LOCAL_BASE_URL` (localhost) |
| `gcp` / `gcp_staging` | `API_GCP_STAGING_BASE_URL` |

Se `API_GCP_STAGING_BASE_URL` estiver vazio ou ainda com `REPLACE_ME` / `XXXX`, o resolver **cai no DO** (não quebra builds). Override: `API_BASE_URL` ou `--dart-define=API_BASE_URL=…`.

Constantes: `lib/services/api_config.dart` (`kCrowdFansGcpStagingApiPlaceholder`).

## Deep links

| Tipo | Config |
|------|--------|
| Custom scheme | `mobile://` (já existia) |
| HTTPS App Links | Android `AndroidManifest.xml` — `crowdfans.app`, `www`, `staging.crowdfans.app` |
| Universal Links | iOS entitlements — `applinks:` nos mesmos hosts |

Hosts: `lib/constants/deep_link_hosts.dart`.  
`Pages.fromIncomingLocation` também stripa path de URLs `https://…`.

**Ainda falta (ops, pós-DNS):** `assetlinks.json` / `apple-app-site-association` nos hosts.

## Relação com SemVer PR

Não bumpa `pubspec`/`VERSION` — isso ficam no PR SemVer (`0.2.0+1`) em `release/0.2`. Este PR é **aditivo**.
