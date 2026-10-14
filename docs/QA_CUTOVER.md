# QA cutover GCP — checklist (CF-360)

**Issue:** [CF-360](https://crowd-fans.youtrack.cloud/issue/CF-360) · épica [CF-356](https://crowd-fans.youtrack.cloud/issue/CF-356)  
**Branch:** `release/0.2` · flavor `APP_FLAVOR=gcp`  
**Live store submit:** humano — este doc só prepara o checklist.

Relacionados: [VERSIONING.md](./VERSIONING.md) · [APP_DISTRIBUTION_GCP.md](./APP_DISTRIBUTION_GCP.md) · [REMOTE_CONFIG_CUTOVER.md](./REMOTE_CONFIG_CUTOVER.md) · [PATROL_GCP_FLAVOR.md](./PATROL_GCP_FLAVOR.md) · GRE live [CF-362](https://crowd-fans.youtrack.cloud/issue/CF-362).

## Aceite

| Item | Como fechar |
|------|-------------|
| Checklist preenchido | Secções abaixo (marcar na release note / YouTrack) |
| `version` x.y.z+build válido | `pubspec.yaml` + `VERSION` alinhados a [VERSIONING.md](./VERSIONING.md) (`0.2.0+N`, sem `-alpha` no CFBundle) |
| Settings mostra versão | UI via `package_info_plus` — validar marketing `0.2.0` + build number |

## Pré-flight (sem store)

- [ ] `git checkout release/0.2 && git pull`
- [ ] `pubspec.yaml` → `version: 0.2.0+N` (bump `+N` a cada build de tester)
- [ ] `VERSION` → SemVer com pré-release se necessário (`0.2.0-alpha.N`) — só git/tag; UI não usa o sufixo
- [ ] `config/gcp.json` aponta Cloud Run `*.run.app` (não `crowdfans-app-*`)
- [ ] `npm run test:unit:gcp` green
- [ ] (opcional Mac) `npm run test:patrol:gcp` green — ver [PATROL_GCP_FLAVOR.md](./PATROL_GCP_FLAVOR.md)

## Green / red / edge (QA manual ou Patrol)

| Classe | Cenário | Esperado |
|--------|---------|----------|
| **Green** | Cold start flavor gcp | Onboarding; API `.run.app` (`apiConfigDebug`) |
| **Green** | Login seed / tester | Home + Settings mostra versão `0.2.0 (N)` |
| **Red** | Credencial inválida | Permanece no login |
| **Red** | Kill-switch RC `cf_cutover_force_digitalocean` (só dual-run) | API cai no host DO vivo documentado — ver Remote Config doc |
| **Edge** | `API_MODE=local` | Loopback; não mistura com staging gcp |
| **Edge** | Host morto `crowdfans-app-prod` / `crowdfans-app-dev*` em env | Fallback staging gcp |

## Bump de versão (prod / tester)

```bash
# 1) editar pubspec.yaml — só o +build na linha GCP
#    version: 0.2.0+42
# 2) opcional: alinhar arquivo VERSION (pré-release git)
# 3) commit na release/0.2 (ou PR)
# 4) Mac: npm run distribute:gcp   # App Dist flutter-testers
#    ou: cf deploy mobile
```

**Não** usar tag SemVer `v0.2.0-*` de Cloud Run para o app mobile.

## Settings / versão na UI

Confirmar após instalar o APK/IPA de tester:

1. Abrir **Configurações** (ou tela que exibe `PackageInfo`).
2. Marketing version = `0.2.0` (sem `-alpha`).
3. Build number = `N` do `pubspec`.

## Fora de escopo deste ticket

- Upload Play/App Store e review Apple/Google
- GRE HTTP live pós-promote → [CF-362](https://crowd-fans.youtrack.cloud/issue/CF-362)
- Ligar triggers Cloud Build mobile → [CF-353](https://crowd-fans.youtrack.cloud/issue/CF-353)
