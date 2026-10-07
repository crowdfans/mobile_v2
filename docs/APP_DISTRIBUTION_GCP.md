# App Distribution — canal `APP_FLAVOR=gcp` (`release/0.2`)

Distribui builds Flutter da linha GCP para testers via Firebase App Distribution  
(projeto `crowdfans-prod`). Coordena [#342](https://github.com/crowdfans/mobile_v2/pull/342) ·  
[API_BACKENDS.md](./API_BACKENDS.md) · [FIREBASE_FLAVORS.md](./FIREBASE_FLAVORS.md).

## Canal vs flavor

| Conceito | Valor default `release/0.2` | Notas |
|----------|----------------------------|--------|
| **Git branch** | `release/0.2` | Integração GCP; `prod` = DO only |
| **APP_FLAVOR** | `gcp` | Android `--flavor gcp` + `config/gcp.json` |
| **App Distribution group** | `flutter-testers` | Mesmo app Firebase; override com `TESTER_GROUP` |
| **Hosting preview (web)** | canal `testers` | Não é App Distribution |
| **pubspec** | `0.2.0+N` | Sem `-alpha` no CFBundle |

Opcional (ops no console Firebase): criar grupo **`flutter-testers-gcp`** e:

```bash
TESTER_GROUP=flutter-testers-gcp npm run distribute:gcp
```

Até o grupo existir, use o default `flutter-testers` — as **release notes** levam prefixo `[gcp]` para distinguir no painel.

## Pré-requisitos

1. `npm install` + `npm run firebase:login` (projeto `crowdfans-prod`)
2. Keys Firebase **locais** nos stubs (`REPLACE_ME_*` no git — ver FIREBASE_FLAVORS.md)
3. Android SDK / Flutter no PATH
4. Testers já no grupo App Distribution (console → App Distribution → Testers)

## Comandos

```bash
# Android flavor gcp → APK → App Distribution (atalho release/0.2)
npm run distribute:gcp
# equivalente:
APP_FLAVOR=gcp npm run distribute:android
./scripts/distribute.sh android

# Só upload (APK já buildado)
APP_FLAVOR=gcp npm run distribute:android:upload

# iOS (signing Apple necessário; sync plist gcp + dart-define)
APP_FLAVOR=gcp npm run distribute:ios

# Web → Hosting preview (não App Distribution)
APP_FLAVOR=gcp npm run distribute:web

# Comparar com DO (não misturar no mesmo release notes sem querer)
APP_FLAVOR=digitalocean npm run distribute:android
```

Artefato Android esperado:

`build/app/outputs/flutter-apk/app-gcp-release.apk`

## Notas de release

O script prefixa `[gcp]` (ou `[digitalocean]`) no texto enviado ao App Distribution:

```text
[gcp] CF-417: Patrol/unit GRE stubs for APP_FLAVOR=gcp
```

Override: `./scripts/distribute.sh android --notes "smoke staging Cloud Run"`  
→ `[gcp] smoke staging Cloud Run`

## Env úteis

| Var | Default | Uso |
|-----|---------|-----|
| `APP_FLAVOR` | `gcp` | Flavor Android + `config/<flavor>.json` |
| `TESTER_GROUP` | `flutter-testers` | Grupo App Distribution |
| `WEB_CHANNEL` | `testers` | Preview Hosting |
| `BUILD_NAME` / `BUILD_NUMBER` | do `pubspec` / stamp | Versionamento do binário |
| `RELEASE_NOTES` | último commit | Texto base (ainda recebe prefixo flavor) |

## Checklist ops (canal gcp)

- [ ] Grupo testers ok (`flutter-testers` ou `flutter-testers-gcp`)
- [ ] APK `app-gcp-release.apk` gerado com `config/gcp.json`
- [ ] Release notes com `[gcp]`
- [ ] Testers instalando build `0.2.0+N` (não `0.1.x` de `prod`)
- [ ] API no app = Cloud Run placeholder até URL real (CF-286+)
- [ ] Não publicar keys Firebase no git

## Fora de escopo

- Criar app Firebase separado por flavor (mesmo `crowdfans-prod` por enquanto)
- Schemes iOS nativos de flavor (só dart-define + sync plist)
- Deploy DO / branch `prod` — outro fluxo, sem este doc
