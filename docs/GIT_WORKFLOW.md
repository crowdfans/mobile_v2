# Git workflow (Flutter)

| Branch | Papel |
|--------|--------|
| **`release/0.2`** | Builds **GCP** — `pubspec` `0.2.0+N`; API Cloud Run após cutover/staging |
| **`prod`** | Canal **DO** vivo — `0.1.x`; API `https://crowdfans-server-prod-h9qb6.ondigitalocean.app` |

PRs de migração GCP: **`--base release/0.2`**. Hotfixes DO: `--base prod`.

Épica: [CF-283](https://crowd-fans.youtrack.cloud/issue/CF-283) · mobile GCP: [CF-356](https://crowd-fans.youtrack.cloud/issue/CF-356). SoT: Project `docs/gcp-git-flow.md`.
