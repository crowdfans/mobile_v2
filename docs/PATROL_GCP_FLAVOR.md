# Patrol / smoke — `APP_FLAVOR=gcp` (CF-417)

**Issue:** [CF-417](https://crowd-fans.youtrack.cloud/issue/CF-417)  
**Coordena:** wiring unit [CF-357](https://crowd-fans.youtrack.cloud/issue/CF-357) / cutover flags · live suite [CF-362](https://crowd-fans.youtrack.cloud/issue/CF-362)  
**HTTP live Cloud Run:** **não** — estes stubs validam flavor → URL placeholder.

## Comandos

```bash
# Unit GRE (wiring API / hosts mortos / edge)
npm run test:unit:gcp
# equivalente:
flutter test \
  test/services/gcp_flavor_gre_test.dart \
  test/services/api_config_test.dart \
  test/services/firebase_options_flavor_test.dart

# Patrol smoke stub (device/emulator; sem assert de rede de negócio)
npm run test:patrol:gcp
# equivalente:
patrol test --flavor gcp --dart-define-from-file=config/gcp.json \
  -t integration_test/gcp_flavor_smoke_test.dart
```

## Aceite → cobertura

| Aceite | Onde |
|--------|------|
| **Green:** default/flavor → `.run.app` staging; Patrol onboarding + `apiConfigDebug` gcp | `gcp_flavor_gre_test.dart` (GREEN) · `gcp_flavor_smoke_test.dart` green |
| **Red:** hosts mortos `crowdfans-app-*` → fallback gcp; login inválido fica no login | GRE RED · Patrol red |
| **Edge:** trailing slash; local loopback; username longo; staging≠prod | GRE EDGE groups |
| **Docs** | Este arquivo |

## Arquivos

| Path | Papel |
|------|--------|
| `test/services/gcp_flavor_gre_test.dart` | Unit green/red/edge |
| `integration_test/gcp_flavor_smoke_test.dart` | Patrol smoke stub |
| `config/gcp.json` | dart-defines Cloud Run staging |
| `lib/services/api_config.dart` | resolução de URL / bloqueio hosts mortos |

## O que não cobre

- Login real + post/comment E2E → `npm run test:patrol:e2e:128` (creds `.env.e2e`; rede live)
- GRE pós-deploy Cloud Run → CF-362
- App Distribution upload → [APP_DISTRIBUTION_GCP.md](./APP_DISTRIBUTION_GCP.md)
