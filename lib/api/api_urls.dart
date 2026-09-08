/// Endpoints do server Go. Sempre usar estas constantes — nunca URL hardcoded.
abstract final class ApiUrls {
  static const authLogin = '/auth/login';
  static const authLoginVerifyToken = '/auth/verifyTokenId';
  static const registerFan = '/register/fan';
  static const registerArtist = '/register/artist';

  static const profile = '/api/v1/profile';
  static const homeFeed = '/api/v1/home';
  static const meWallet = '/api/v1/me/wallet';
  static const jamCoinPacks = '/api/v1/jam-coin-packs';
  static const searchArtists = '/api/v1/search/artists';
  static const fanClubs = '/api/v1/follows';
}
