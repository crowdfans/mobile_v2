# Git workflow (Flutter)

| Branch | Papel |
|--------|--------|
| **`release/0.2`** | Builds **GCP** — `pubspec` `0.2.0+N`; API Cloud Run |

PRs: **`--base release/0.2`**. Deploy por tag `v0.2.0-*`. Sem DigitalOcean operacional.

**API:** `https://crowdfans-server-peefddw6nq-rj.a.run.app` · financial `https://crowdfans-financial-peefddw6nq-rj.a.run.app`. Local: `API_MODE=local`.

Épica: [CF-283](https://crowd-fans.youtrack.cloud/issue/CF-283) · mobile GCP: [CF-356](https://crowd-fans.youtrack.cloud/issue/CF-356). SoT: Project `docs/gcp-git-flow.md`.
