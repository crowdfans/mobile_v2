# API hosts — GCP Cloud Run

**Task:** [CF-361](https://crowd-fans.youtrack.cloud/issue/CF-361) · **Épica:** [CF-356](https://crowd-fans.youtrack.cloud/issue/CF-356) · docs: [CF-372](https://crowd-fans.youtrack.cloud/issue/CF-372)  
**Branch SoT:** Project `docs/gcp-git-flow.md` (`release/0.2` = GCP)  
**Related:** flavors/env wiring (CF-357+).

> Docs-only. Sem DigitalOcean operacional.

---

## Proibido (sempre)

| Host | Motivo |
|------|--------|
| `crowdfans-app-dev*` | DNS morto |
| `crowdfans-app-prod.ondigitalocean.app` | DNS morto |
| `crowdfans-server-prod-*.ondigitalocean.app` (incl. `h9qb6`) | DNS morto / não operacional |

Nunca usar como fallback, exemplo de `.env`, ou “dev default”.

---

## Canal operacional

| Linha | Git | Versão app | API canônica |
|-------|-----|------------|--------------|
| **GCP** | `release/0.2` | `0.2.0+N` | `https://crowdfans-server-peefddw6nq-rj.a.run.app` · financial `https://crowdfans-financial-peefddw6nq-rj.a.run.app` |
| **Local** | qualquer | — | `API_MODE=local` → `http://localhost:8080` |

Custom domain alvo (futuro): `api.crowdfans.app` — Project `docs/gcp-edge-armor-lb-dns.md`.

Override forçado: `API_BASE_URL` / `--dart-define=API_BASE_URL=…`.

---

## O que agents devem fazer

| Checkout | Apontar API para |
|----------|------------------|
| `release/0.2` / feature GCP | Cloud Run URIs acima |
| Debug local | `API_MODE=local` |

Rules: `.cursor/rules/api-prod-only.mdc` · resumo em `AGENTS.md`.
