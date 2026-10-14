# Remote Config / feature flags — cutover GCP (`CF-359`)

Linha **`release/0.2`**. Flags para dual-run API/mídia e **kill-switch** de rollback URL.  
Code: `lib/services/cutover_flags.dart` · template: `remoteconfig/cutover_template.json`.

## Aceite

| Critério | Status |
|----------|--------|
| Flag documentada | Este doc + chaves abaixo + template JSON |
| Kill-switch rollback URL | `cf_cutover_force_digitalocean` → API DO viva |

## Hydrate (ordem)

1. **Firebase Remote Config** (live) — só se `FirebaseService.usingStubOptions == false`
2. `CutoverFlags.applyRemoteValues({…})` (mapa RC / fixture / testes)
3. `--dart-define=cf_*=…`
4. `.env`: `CF_CUTOVER_FORCE_DIGITALOCEAN`, `CF_API_BACKEND`, `CF_MEDIA_BACKEND`, `CF_API_BASE_URL`

Com stubs `REPLACE_ME_*` ([FIREBASE_FLAVORS.md](./FIREBASE_FLAVORS.md)), `bootstrap()` **não** faz fetch (fail-safe). Env / dart-define / `applyRemoteValues` continuam válidos.

`main.dart`: `FirebaseService.initialize()` → `CutoverFlags.bootstrap()`.

Fail-open: erro de rede/RC não derruba o app.

## Defaults seguros

Sem override → flavor atual (`APP_FLAVOR=gcp` → Cloud Run + GCS).  
**Não** muda o default da linha 0.2 para DO; o kill-switch é o caminho de rollback em dual-run.

Para um build **digitalocean** (linha `prod` / flavor DO), defaults já são DO — flags só sobrescrevem se setadas.

## Parâmetros (Firebase RC = mesmos nomes)

| Key | Tipo | Efeito |
|-----|------|--------|
| `cf_cutover_force_digitalocean` | bool (`true`/`1`/`yes`) | **Kill-switch**: `apiBaseUrl` → DO server-prod; mídia → Spaces |
| `cf_api_backend` | string | `gcp` \| `gcp_prod` \| `digitalocean` \| `local` |
| `cf_media_backend` | string | `gcs` \| `spaces` |
| `cf_api_base_url` | string URL | Override absoluto (hosts mortos rejeitados). **Ignorado** se kill-switch ON |

### Prioridade `apiBaseUrl`

1. Kill-switch DO  
2. `API_BASE_URL` (dart-define / env legado)  
3. `cf_api_base_url`  
4. Mode (`cf_api_backend` / `API_MODE` / flavor) → Cloud Run ou DO  

## Console Firebase / template

Template versionado (defaults **neutros**):

```bash
# NÃO deployar no batch-then-ship — só quando Gustavo autorizar ship:
# npx firebase-tools@latest deploy --only remoteconfig --project=crowdfans-prod
```

`firebase.json` aponta `remoteconfig.template` → `remoteconfig/cutover_template.json`.

Em incidente dual-run (após template publicado + keys reais no app):

1. Console Firebase → Remote Config → `cf_cutover_force_digitalocean=true`
2. Publicar  
3. Apps buscam no próximo cold start (`bootstrap` / fetch; release min interval 1h)

## Testes GRE

```bash
flutter test test/services/cutover_flags_test.dart
```

## Relacionados

- [API_BACKENDS.md](./API_BACKENDS.md) — flavors / Cloud Run  
- [MEDIA_GCS.md](./MEDIA_GCS.md) — shapes GCS  
- [STORAGE_AUTH_CLIENTS.md](./STORAGE_AUTH_CLIENTS.md) — Bearer vs signed PUT  
- [FIREBASE_FLAVORS.md](./FIREBASE_FLAVORS.md) — stubs vs keys reais  
