# API hosts — GCP Cloud Run vs DigitalOcean

**Task:** [CF-361](https://crowd-fans.youtrack.cloud/issue/CF-361) · **Épica:** [CF-356](https://crowd-fans.youtrack.cloud/issue/CF-356)  
**Branch SoT:** Project `docs/gcp-git-flow.md` (`release/0.2` = GCP · `prod` = DO)  
**Related:** flavors/env wiring may land em PRs CF-357 ([mobile_v2#342](https://github.com/crowdfans/mobile_v2/pull/342) / [#343](https://github.com/crowdfans/mobile_v2/pull/343)); este doc é a **fonte agent-facing** de hosts.

> Docs-only (CF-361). Sem mudança de clients de mídia (CF-358).

---

## Proibido (sempre)

| Host | Motivo |
|------|--------|
| `crowdfans-app-dev*` | DNS morto |
| `crowdfans-app-prod.ondigitalocean.app` | DNS morto |

Nunca usar como fallback, exemplo de `.env`, ou “dev default”.

---

## Duas linhas (até cutover)

| Linha | Git | Versão app | API canônica |
|-------|-----|------------|--------------|
| **DO (usuários hoje)** | `prod` | `0.1.x+build` | `https://crowdfans-server-prod-h9qb6.ondigitalocean.app` |
| **GCP (integração)** | `release/0.2` | `0.2.0+N` | Cloud Run **server** — ver placeholders abaixo |

Pós-cutover (`v0.2.0`): canônico = Cloud Run / custom domain (`api.crowdfans.app` alvo — Project `docs/gcp-edge-armor-lb-dns.md`). DO deixa de ser alvo de agents.

---

## Placeholders GCP (CF-286)

Até Cloud Run existir:

| Uso | Placeholder / env |
|-----|-------------------|
| Staging | `API_GCP_STAGING_BASE_URL` → `https://REPLACE_ME-crowdfans-server-staging-XXXX.southamerica-east1.run.app` |
| Custom host (alvo) | `https://api.staging.crowdfans.app` |
| Prod GCP (cutover) | `https://api.crowdfans.app` / Cloud Run `crowdfans-server` |

Modos: `API_MODE=gcp` / `gcp_staging` (e flavors `APP_FLAVOR=gcp` quando o PR de flavors mergear).  
Unresolved `REPLACE_ME` / `XXXX` → resolver do app deve **cair no DO** (não nos hosts mortos).

`API_MODE=local` → `http://localhost:8080` (ok).

Override forçado: `API_BASE_URL` / `--dart-define=API_BASE_URL=…`.

---

## O que agents devem fazer

| Checkout | Apontar API para |
|----------|------------------|
| `prod` / hotfix DO | server-prod DO |
| `release/0.2` / feature GCP | Cloud Run via `API_GCP_*` (placeholder ok) |
| Debug local | `API_MODE=local` |

Rules: `.cursor/rules/api-prod-only.mdc` · resumo em `AGENTS.md`.
