# Remote Config / feature flags — cutover GCP (`CF-359`)

Linha **`release/0.2`**. Flags para dual-run API/mídia e **kill-switch** de rollback URL.  
PR [#342](https://github.com/crowdfans/mobile_v2/pull/342) · code: `lib/services/cutover_flags.dart`.

## Aceite

| Critério | Status |
|----------|--------|
| Flag documentada | Este doc + chaves abaixo |
| Kill-switch rollback URL | `cf_cutover_force_digitalocean` → API DO viva |

## Por que sem pacote `firebase_remote_config` ainda

Options Firebase nesta linha ainda são stubs `REPLACE_ME_*` ([FIREBASE_FLAVORS.md](./FIREBASE_FLAVORS.md)). Fetch live do RC falharia / exigiria secrets.  
**Mesmas chaves** que o console Firebase; hydrate hoje via:

1. `CutoverFlags.applyRemoteValues({…})` (mapa RC / fixture)
2. `--dart-define=cf_*=…`
3. `.env`: `CF_CUTOVER_FORCE_DIGITALOCEAN`, `CF_API_BACKEND`, `CF_MEDIA_BACKEND`, `CF_API_BASE_URL`

Quando apiKey real existir: fetch RC → `applyRemoteValues` no `bootstrap()` (hook já em `main.dart`).

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

## Console Firebase (quando keys reais)

Criar parâmetros com defaults **neutros** (vazio / `false`) para builds gcp.  
Em incidente dual-run: set `cf_cutover_force_digitalocean=true` → publicar → apps buscam RC no próximo `bootstrap`/fetch.

## Testes GRE

```bash
flutter test test/services/cutover_flags_test.dart
```

## Relacionados

- [API_BACKENDS.md](./API_BACKENDS.md) — flavors / Cloud Run  
- [MEDIA_GCS.md](./MEDIA_GCS.md) — shapes GCS  
- [STORAGE_AUTH_CLIENTS.md](./STORAGE_AUTH_CLIENTS.md) — Bearer vs signed PUT  
