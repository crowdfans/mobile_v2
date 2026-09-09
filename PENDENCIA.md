# Pendências — `mobile_v2`

O que **você** precisa fazer, o que espera o Expo, e o que o agente continua no `TODO.md`.

---

## 1. IPA iOS no App Distribution — **você faz agora**

Xcode 26.6, license e platform iOS 26.5 já estão ok. Falta só a conta Apple no Xcode (hoje: **0 certificados**).

Bundle Flutter: `com.crowdfans.crowdfans` (o Expo continua `com.crowdfans.crowdfansmobile` — outro app).

### Passo a passo

1. Abra o workspace (já pode estar aberto):
   `ios/Runner.xcworkspace`  
   Se não abrir: Finder → `mobile_v2/ios/Runner.xcworkspace`.
2. No Xcode: **Xcode → Settings… → Accounts**.
3. **+** → **Apple ID** → entre com o Apple ID do **time CrowdFans** (conta paga do Apple Developer Program).
4. Confira que o team aparece (Team ID). Sem membership paga o App Distribution iOS não assina para testers.
5. No navigator: projeto **Runner** → target **Runner**.
6. Aba **Signing & Capabilities**:
   - marque **Automatically manage signing**
   - **Team** = o time CrowdFans
   - Bundle Identifier = `com.crowdfans.crowdfans`
   - Signing Certificate deve virar **Apple Development** (ou Distribution). Sem aviso vermelho.
7. Na primeira vez a Apple pode pedir para criar o App ID `com.crowdfans.crowdfans`. Deixe o Xcode criar.
8. Avise no chat. O restante é daqui:
   - `flutter build ipa --release --export-method ad-hoc`
   - `npm run distribute:ios` (grupo `flutter-testers`, projeto `crowdfans-prod`)

**Não precisa** consertar CocoaPods. Este app usa Swift Package Manager.

---

## 2. Testar o APK Android — **você faz se quiser**

Já enviado. Testers no grupo: `crowdfans@gmail.com` e `gus@crowdfans.app`.

1. Abra o [release no console](https://console.firebase.google.com/project/crowdfans-prod/appdistribution/app/android:com.crowdfans.crowdfans/releases/2a1kimr08lgc0?utm_source=firebase-tools) ou o e-mail do Firebase.
2. No celular Android: instale o **App Tester** (Firebase) e aceite o convite.
3. Instale o `0.1.0-alpha.1 (1)`.
4. Login: conta Firebase de produção (`crowdfans@gmail.com`).

Para mais testers: mande os e-mails. Eu adiciono no grupo `flutter-testers`.

---

## 3. OTP na **web** (reCAPTCHA) — **você no console Firebase, se for testar web**

OTP no iOS/Android nativo usa Play/APNs. Na **web** o Firebase exige reCAPTCHA.

1. [Firebase Console](https://console.firebase.google.com/project/crowdfans-prod/authentication/providers) → Authentication → Sign-in method → **Phone**.
2. Confira que o app web `crowdfans-prod` está autorizado (já existe: `1:658897248078:web:719078048f5878412c881f`).
3. Domínio autorizado: o host que você usa no Flutter web (localhost na dev).
4. Avisar no chat para ligar o verifier no Flutter (equivalente ao `FirebaseRecaptchaVerifierModal` do Expo).

Sem isso, cadastro/login por SMS **no browser** continua quebrado. Nativo não depende deste passo.

---

## 4. Não implementar (espera o Expo)

| Item | Por quê |
| --- | --- |
| Social login (Google/Apple) | Comentado no `mobile`. Só quando o Expo ligar. |
| Live / Meet & Greet | ⛔ no Expo. Não inventar. |
| Create post de fã | ⛔ no Expo se continuar assim. |
| Cadastro artista: Spotify / parental | O Expo também não tem tela. Copiamos o buraco. |

Horus / `horus-admin` continua fora.

---

## 5. Trabalho de código (agente / `TODO.md`) — **não é passo seu**

Ordem quando o IPA estiver no ar (ou em paralelo, se você preferir):

1. ~~Fan club about / rules / moderação + `FanClubViewerService`~~
2. ~~Perfil público do fã + fan score + artistas seguidos~~
3. Settings que faltam: fan score, wallet, Pro, ganhos, referral, insights
4. Fan letters
5. ~~Push (FCM/APNs)~~ (token sync + entitlements + deep link ao tocar)
6. RevenueCat (`purchases_flutter`) + Jam Coins IAP (WS da carteira já no app)
7. Remover `DemoScreen`

**Push iOS (humano / console):** chave APNs do Apple Developer precisa estar no Firebase `crowdfans-prod` (Project settings → Cloud Messaging) para FCM entregar no iPhone.

Firebase CLI, apps nativos e APK Android **já estão feitos**.

---

## Já resolvido (não mexer)

- `flutterfire configure` no `crowdfans-prod` (iOS/Android `com.crowdfans.crowdfans` + web)
- `firebase_options.dart`, `google-services.json`, `GoogleService-Info.plist`
- CLI: `node_modules/.bin/firebase`, conta `crowdfans@gmail.com`
- Grupo App Distribution `flutter-testers`
- APK Android `0.1.0-alpha.1 (1)` no Distribution
- License do Xcode + download iOS 26.5
