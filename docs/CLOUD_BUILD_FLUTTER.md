# Cloud Build — artifacts Flutter (CF-353)

**Issue:** [CF-353](https://crowd-fans.youtrack.cloud/issue/CF-353) · épica [CF-348](https://crowd-fans.youtrack.cloud/issue/CF-348)  
**Repos:** `mobile_v2`, `cloud`  
**Apply / upload:** **não** neste draft — triggers ficam `disabled` / `_DISTRIBUTE=false`.

## Decisão

| Pergunta | Resposta |
|----------|----------|
| Cloud Build substitui o fluxo Mac de App Distribution? | **Não** — caminho operacional continua `cf deploy mobile` → Mac → `scripts/distribute.sh` |
| Cloud Build gera APK? | **Opcional e mínimo** — CI Android APK (`cloudbuild.yaml`), sem upload |
| App Distribution a partir do Cloud Build? | **Opcional e gated** (`cloudbuild.distribute.yaml`, `_DISTRIBUTE=false` por default) |
| IPA / TestFlight no Cloud Build? | **Não** — codesign / Keychain / ASC só no Mac |

### Por quê

1. Happy path já é Firebase-only no Mac (`flutter-testers` + Hosting `testers`).
2. iOS não fecha o loop em Linux Cloud Build.
3. Versionamento mobile = branch + `pubspec.yaml` `name+number` — **não** tags SemVer `v0.2.0-*` dos serviços Cloud Run.
4. Custo/complexidade de imagem Flutter+Android SDK vs Mac always-on.

## Arquivos

| Arquivo | Papel |
|---------|--------|
| [`cloudbuild.yaml`](../cloudbuild.yaml) | CI: analyze/test + `flutter build apk --release` → artifact GCS (quando bucket existir) |
| [`cloudbuild.distribute.yaml`](../cloudbuild.distribute.yaml) | Manual: App Dist Android **só** se `_DISTRIBUTE=true` e `_DRY_RUN=false` |
| `cloud` `cloudbuild/triggers.example.yaml` | Triggers exemplo `disabled: true` |

## Versionamento (aceite)

| Surface | Regra |
|---------|--------|
| Linha GCP | branch `release/0.2`, `pubspec` `0.2.0+N` — ver [VERSIONING.md](./VERSIONING.md) |
| App Dist Mac | `cf deploy mobile` (ref configurável; canal gcp = [APP_DISTRIBUTION_GCP.md](./APP_DISTRIBUTION_GCP.md)) |
| Cloud Run | tags `v0.2.0-*` — **ortogonal**; não reutilizar para mobile |

## Ship checklist (humano, depois)

1. Merge deste draft + triggers exemplo no `cloud`.
2. Bucket GCS de artifacts **ou** remover bloco `artifacts:` do YAML.
3. (Opcional) imagem custom Flutter+Android no Artifact Registry.
4. Smoke: um build manual com `_DISTRIBUTE=false` → só APK.
5. Só se necessário: Secret Manager `FIREBASE_TOKEN` + flip `_DISTRIBUTE=true` no trigger manual.

Até lá, testers = Mac App Distribution.
