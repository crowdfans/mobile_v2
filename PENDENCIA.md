# Pendências — `mobile_v2`

Itens do `TODO.md` que não dá para fechar agora. Revisar e destravar.

## flutterfire configure (`crowdfans-prod`)

**TODO:** `google-services.json` / `GoogleService-Info.plist` / `lib/firebase_options.dart`

O `admin@crowdfans.app` aparece logado no CLI, mas o access token está expirado (refresh 400 → API 401). Sem reauth o `flutterfire configure` e o `firebase apps:list` não rodam.

O que já está no repo:

- `.firebaserc` aponta para `crowdfans-prod`
- `package.json` com `firebase-tools`
- Auth no Dart usa as chaves web do `.env` (`EXPO_PUBLIC_FIREBASE_*`)

O que falta depois do login:

```bash
npx firebase-tools@latest login --reauth
dart pub global activate flutterfire_cli
dart pub global run flutterfire_cli:flutterfire configure \
  --project=crowdfans-prod --platforms=ios,android,web --yes
```

Trocar `FirebaseService` para `DefaultFirebaseOptions.currentPlatform`.

App Distribution só depois disso.

Bundle Flutter atual: `com.crowdfans.crowdfans`. Expo: `com.crowdfans.crowdfansmobile`. Decidir se reusa o app nativo do Expo ou cria um novo no console.

## Social login

Comentado no Expo. **Não implementar** até o `mobile` ligar.

## Cadastro: reCAPTCHA nativo / web

OTP SMS no Flutter nativo usa `verifyPhoneNumber` (Play/APNs). Na **web** o Firebase exige reCAPTCHA — bloqueado até o `flutterfire configure` e um slot web equivalente ao `FirebaseRecaptchaVerifierModal`.

## Ainda no `TODO.md` (não bloqueado, só não deu neste corte)

Cadastro artista, comunidade do fan club, telas filhas de settings, create post, comentários, fan letters, notificações, denúncia, RevenueCat/IAP, wallet WS, push/FCM.

Continuar a partir da seção 4 do `TODO.md`.

Ainda faltam no feed: `PostOptionsSheet`, share nativo, chips Live/Meet, `SubscriptionService` para unlock de membership (hoje o card exclusivo só olha `exclusiveLocked` + se o viewer é artista).
