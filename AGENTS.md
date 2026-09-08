# Flutter (mobile_v2)

Migração a partir de `crowdfans/mobile` (Expo). Comportamento esperado: o app Expo. Implementação: padrões Flutter abaixo.

## Rotas e API

- Navegação só por `Pages` em `lib/constants/pages.dart`
- HTTP só por `ApiUrls` em `lib/api/api_urls.dart` via `HttpService.request`

## Serviços

Facade em objeto (`AuthService.loginBackendWithFirebaseToken`), não funções soltas como API pública.

## Idioma

Comentários, dartdoc e mensagens de UI em português.

## Telas

Estado da tela fica no arquivo da tela. Extraia widget só quando o bloco tiver responsabilidade visual própria (`lib/widgets/`).
