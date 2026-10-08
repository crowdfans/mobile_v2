# Firebase por APP_FLAVOR (gcp vs digitalocean)

Coordena com [API_BACKENDS.md](./API_BACKENDS.md) e PR [#342](https://github.com/crowdfans/mobile_v2/pull/342).

## Princípio

- Stubs **sem segredos** no git (`REPLACE_ME_*`).
- Keys reais: `flutterfire configure` local / CI secret — **não** commit.
- Auth/FCM hoje = projeto `crowdfans-prod` (ambos os flavors até haver app Firebase dedicado).

## Arquivos

| Flavor | Dart | Android | iOS stub |
|--------|------|---------|----------|
| `gcp` | `lib/firebase_options_gcp.dart` | `android/app/src/gcp/google-services.json` | `ios/Firebase/gcp/GoogleService-Info.plist` |
| `digitalocean` | `lib/firebase_options_digitalocean.dart` | `android/app/src/digitalocean/google-services.json` | `ios/Firebase/digitalocean/GoogleService-Info.plist` |

Seletor: `lib/firebase_options.dart` → `DefaultFirebaseOptions` usa `appFlavor()`.

`ios/Runner/GoogleService-Info.plist` é gerado/copiado do stub:

```bash
./scripts/sync_firebase_flavor.sh gcp
./scripts/run_backend.sh digitalocean   # já sincroniza
```

## Preencher keys (local)

1. `npx firebase-tools@latest login --reauth`
2. `flutterfire configure --project=crowdfans-prod --platforms=ios,android,web --yes`
3. Copiar apiKey/appId gerados para o stub do flavor **ou** para um override local não commitado.
4. Nunca reintroduzir keys no `release/0.2` / PRs GCP.

Branch `prod` (DO `0.1.x`) pode continuar com o configure histórico — fora deste PR.

## App Distribution

Canal testers para builds `APP_FLAVOR=gcp`: [APP_DISTRIBUTION_GCP.md](./APP_DISTRIBUTION_GCP.md)  
(`npm run distribute:gcp` → grupo `flutter-testers`, notes `[gcp] …`).
