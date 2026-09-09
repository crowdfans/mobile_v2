# Flutter — CrowdFans (`mobile_v2`)

Reescrita do Expo em `../mobile`. Comportamento: o app Expo. Código: padrões deste arquivo e `.cursor/rules/`.

Não copiar `frontendapp/` (Flutter legado / Supabase).

---

## Telas vs componentes

- Tela = `lib/screens/.../*_screen.dart`. Estado, handlers e `Scaffold` ficam **na tela**.
- Qualquer bloco visual próprio (slide, botão, form, row, card, ícone de tab) é **widget em arquivo próprio**.
- **Proibido** `class _Foo extends StatelessWidget` / `StatefulWidget` dentro da tela (exceto o `State` da própria tela: `_FooScreenState`).
- Pasta: `lib/components/<domínio>/`. Um widget público por arquivo. Nome do arquivo = nome da classe em snake_case.

```
lib/components/
  onboarding/presentation_slide.dart
  onboarding/onboarding_buttons.dart
  login/credentials_form.dart
  navigation/main_tab_icon.dart
```

```dart
// ❌ na tela
class _Slide extends StatelessWidget { ... }

// ✅
// lib/components/onboarding/presentation_slide.dart
class PresentationSlide extends StatelessWidget { ... }
```

Dados do widget (ex.: título/subtítulo do slide) vão no mesmo arquivo do widget, não na tela.

---

## Rotas e API

- Navegação só com `Pages` (`lib/constants/pages.dart`).
- HTTP só com `ApiUrls` + `HttpService.request`. Sem URL hardcoded.

---

## Serviços

`export abstract final class XxxService` (ou `class XxxService` com métodos estáticos agrupados). Sem funções soltas como API pública.

```dart
abstract final class AuthService {
  static Future<void> loginBackendWithFirebaseToken(String idToken) async { ... }
}
```

---

## Idioma

Comentários, dartdoc e mensagens de UI em **português**.

---

## Funções

Na UI: `void handleLogin() async { }` / `Future<void> handleLogin() async { }`. Evitar `final handler = () {}` sem motivo.

---

## Firebase

Projeto: **`crowdfans-prod`** (não `crowdfans-dev-e9703`). CLI: `npx firebase-tools@latest` neste repo (`.firebaserc`).

1. `npx firebase-tools@latest login --reauth` (o token local costuma expirar; `login:list` mentindo “logged in” ainda dá 401).
2. `dart pub global activate flutterfire_cli`
3. `flutterfire configure --project=crowdfans-prod --platforms=ios,android,web --yes`
4. Trocar `FirebaseService` para `DefaultFirebaseOptions.currentPlatform`.

App Distribution, `google-services.json` e o plist **só** saem desse configure — copiar a chave web do Expo no `.env` cobre Auth no Dart, não o app nativo.

O `.env` aceita as mesmas chaves do Expo (`EXPO_PUBLIC_FIREBASE_*`, `EXPO_PUBLIC_API_*`).

**API:** nunca `crowdfans-app-dev*`. Default DigitalOcean = `https://crowdfans-app-prod.ondigitalocean.app`. Localhost só com `API_MODE=local`.

---

## Layout

Fonte: prints nas tasks YouTrack (CF-66 Superfã, CF-109 Artista) e `Downloads/Screens/{Superfã,Artista}`. O Flutter atual **não** é a referência — se divergir, o app muda, o mock não. Sem print, não inventar tela.

## Checklist

- [ ] Widget visual não está privado na tela
- [ ] Arquivo em `lib/components/<domínio>/`
- [ ] `Pages.*` / `ApiUrls.*`
- [ ] Sem `print` de debug na entrega
- [ ] Layout igual ao print da task (não ao código legado)
