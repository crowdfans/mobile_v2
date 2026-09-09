# Pendências — `mobile_v2`

Itens do `TODO.md` que não dá para fechar agora. Revisar e destravar.

## flutterfire configure (`crowdfans-prod`)

Feito: apps nativos `com.crowdfans.crowdfans` (iOS/Android) + web existente, `lib/firebase_options.dart`, `google-services.json`, `GoogleService-Info.plist`. `FirebaseService` usa `DefaultFirebaseOptions.currentPlatform`.

O CLI precisa do binário `firebase` no PATH (`node_modules/.bin` deste repo, via `firebase-tools`). Conta atual: `crowdfans@gmail.com`.

App Distribution: o console aceita upload, mas ainda falta grupo de testers e um IPA/APK para distribuir. Script: `npm run firebase -- appdistribution:distribute`.

Bundle Flutter: `com.crowdfans.crowdfans`. Expo permanece `com.crowdfans.crowdfansmobile`.

## Social login

Comentado no Expo. **Não implementar** até o `mobile` ligar.

## Cadastro: reCAPTCHA nativo / web

OTP SMS no Flutter nativo usa `verifyPhoneNumber` (Play/APNs). Na **web** o Firebase exige reCAPTCHA — o app web já existe no console; falta o slot equivalente ao `FirebaseRecaptchaVerifierModal`.

## AppRootLayout — RevenueCat

Fontes e tema já sobem no `CrowdFansApp`. `PurchasesService.configure()` no start só entra quando o SDK (`purchases_flutter`) for ligado (seção 16).

## Cadastro artista — Spotify / parental (⛔)

O Expo também não tem tela de verificação Spotify, contestação de nome nem consentimento parental. O Flutter copiou o buraco: enums no model, sem UI e sem endpoint extra.

## Ainda no `TODO.md` (não bloqueado)

Fan club compose/about, settings filhas, fan letters, notificações/FCM, RevenueCat/IAP, wallet WS.
