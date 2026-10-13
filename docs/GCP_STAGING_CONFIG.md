# GCP API base URL + deep links

**Branch:** `release/0.2` · **Épica:** CF-356

## API (live Cloud Run)

| `API_MODE` | Base URL |
|------------|----------|
| `gcp` / `gcp_staging` / `gcp_prod` / `prod` | `https://crowdfans-server-peefddw6nq-rj.a.run.app` |
| `local` | `API_LOCAL_BASE_URL` (localhost) |
| `digitalocean` | `API_DIGITALOCEAN_BASE_URL` (legado; não default) |

Financial (não é base do app mobile; server/scripts): `https://crowdfans-financial-peefddw6nq-rj.a.run.app`.

Constantes: `lib/services/api_config.dart` (`kCrowdFansGcpApi`, `kCrowdFansGcpFinancialApi`).

Override: `API_BASE_URL` ou `--dart-define=API_BASE_URL=…`.

## Deep links

Hosts: `lib/constants/deep_link_hosts.dart` (`crowdfans.app`, `staging.crowdfans.app` placeholder até DNS edge).
