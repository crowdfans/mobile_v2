# Patrol / smoke — `APP_FLAVOR=gcp` (placeholders)

Pré-deploy Cloud Run (CF-286+). Valida **wiring** flavor → URL, não API live.  
Live G/R/E pós-cutover: [CF-362](https://crowd-fans.youtrack.cloud/issue/CF-362).

Coordena [API_BACKENDS.md](./API_BACKENDS.md) · [FIREBASE_FLAVORS.md](./FIREBASE_FLAVORS.md) · PR [#342](https://github.com/crowdfans/mobile_v2/pull/342).

## Como rodar

```bash
# Unit GRE (sempre; sem emulador)
flutter test test/services/gcp_flavor_gre_test.dart

# Patrol smoke stub (emulador/device + flavor gcp)
npm run test:patrol:gcp
# = patrol test --flavor gcp --dart-define-from-file=config/gcp.json \
#     -t integration_test/gcp_flavor_smoke_test.dart

# Smokes genéricos já no flavor gcp
npm run test:patrol:smoke
npm run test:patrol:superfan
```

Placeholder em `config/gcp.json`:

`https://crowdfans-server-staging.southamerica-east1.run.app`

## Matriz green / red / edge

| | Unit (`gcp_flavor_gre_test`) | Patrol (`gcp_flavor_smoke_test`) |
|--|------------------------------|----------------------------------|
| **Green** | default/flavor → `.run.app` staging; sem DO | onboarding sobe; `apiConfigDebug` = gcp + `.run.app` |
| **Red** | hosts mortos `crowdfans-app-*` → fallback gcp; URL vazia não cai em DO | login inválido permanece no login |
| **Edge** | trailing `/`; `API_MODE=local` loopback; debug mode:base; staging≠prod | username longo; campos login; mode ainda gcp |

## Fora de escopo (até Cloud Run live)

- Login/feed/upload reais contra staging GCP → CF-362
- Offline / deep link / contagem zero na API → CF-362
- Firebase keys reais (stubs `REPLACE_ME_*`) → configure local/CI

## Aceite stub

- [x] Unit GRE green/red/edge
- [x] Patrol smoke green/red/edge (device)
- [x] Scripts npm / docs nesta página
- [ ] CF-362 quando URL `.run.app` real existir
