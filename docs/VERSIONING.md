# Versionamento (mobile_v2)

SoT: Project `docs/gcp-git-flow.md` (**LOCKED**).

| Linha | Branch | `pubspec` | Tag Git |
|-------|--------|-----------|---------|
| DO | `prod` | `0.1.x+build` | `v0.1.…` (histórico) |
| GCP | `release/0.2` | **`0.2.0+N`** (sem `-alpha` no CFBundle) | `v0.2.0-alpha.N` |

Arquivo `VERSION` guarda o SemVer com pré-release (`0.2.0-alpha.1`). UI usa `package_info_plus` (marketing = `0.2.0`).

Cutover QA + bump: [QA_CUTOVER.md](./QA_CUTOVER.md) (CF-360).
Patrol gcp stubs: [PATROL_GCP_FLAVOR.md](./PATROL_GCP_FLAVOR.md) (CF-417).
