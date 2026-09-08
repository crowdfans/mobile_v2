# CrowdFans mobile_v2 (Flutter)

Reescrita do app Expo em [`crowdfans/mobile`](https://github.com/crowdfans/mobile) para Flutter.

## Rodar

```bash
export PATH="$HOME/sdk/flutter/bin:$PATH"   # se o Flutter não estiver no PATH
cp .env.example .env                        # opcional; o app já carrega .env.example
flutter pub get
flutter run
```

API padrão: DigitalOcean **dev**. Para o Go local:

```
API_MODE=local
API_LOCAL_BASE_URL=http://localhost:8080
```

Login usa o mesmo projeto Firebase `crowdfans-dev` do Expo.

## Estrutura

Espelha o mobile Expo:

- `lib/constants/pages.dart` — rotas (`Pages.*`)
- `lib/api/api_urls.dart` — endpoints (`ApiUrls.*`)
- `lib/services/` — facade (`AuthService`, `HttpService`, `ProfileService`)
- `lib/screens/` — telas (estado da tela no próprio arquivo)

## Migração

Ver `MIGRATION.md`. O Expo em `../mobile` continua sendo a referência de comportamento até cada tela ser marcada como feita.
