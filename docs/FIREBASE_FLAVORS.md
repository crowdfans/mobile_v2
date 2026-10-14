# Firebase por APP_FLAVOR (gcp)

Coordena com [API_BACKENDS.md](./API_BACKENDS.md). Happy path = **gcp**. Flavor `digitalocean` no tree é arquivo de cutover — não CI ([CF-354](https://crowd-fans.youtrack.cloud/issue/CF-354)).

## Princípio

- Stubs **sem segredos** no git (`REPLACE_ME_*`).
- Keys reais: `flutterfire configure` local / CI secret — **não** commit.
- Auth/FCM = projeto `crowdfans-prod`.

## Arquivos

| Flavor | Dart | Android | iOS stub |
|--------|------|---------|----------|
| `gcp` | `lib/firebase_options_gcp.dart` | `android/app/src/gcp/google-services.json` | `ios/Firebase/gcp/GoogleService-Info.plist` |

Seletor: `lib/firebase_options.dart` → `DefaultFirebaseOptions` usa `appFlavor()`.

`ios/Runner/GoogleService-Info.plist` é gerado/copiado do stub:

```bash
./scripts/sync_firebase_flavor.sh gcp
./scripts/run_backend.sh gcp
```

## Preencher keys (local)

1. `npx firebase-tools@latest login --reauth`
2. `flutterfire configure --project=crowdfans-prod --platforms=ios,android,web --yes`
3. Copiar apiKey/appId gerados para o stub do flavor **ou** para um override local não commitado.
4. Nunca reintroduzir keys no `release/0.2` / PRs GCP.

## App Distribution

Canal testers para builds `APP_FLAVOR=gcp` ([CF-418](https://crowd-fans.youtrack.cloud/issue/CF-418)):  
[APP_DISTRIBUTION_GCP.md](./APP_DISTRIBUTION_GCP.md)  
(`npm run distribute:gcp` → grupo `flutter-testers`, notes `[gcp] …`).
