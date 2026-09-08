/// Rotas do app — única fonte de verdade (espelho de `page_list.ts`).
abstract final class Pages {
  static const presentation = '/onboarding/presentation';
  static const loginFan = '/login/fan';
  static const loginArtist = '/login/artist';
  static const registerFan = '/register/fan';
  static const registerArtist = '/register/artist';

  static const home = '/feed';
  static const clubs = '/clubs';
  static const explore = '/explore';
  static const me = '/me';

  static const publicPrefixes = [
    '/onboarding',
    '/login',
    '/register',
  ];
}
