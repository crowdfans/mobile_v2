/// Endpoints do server Go. Sempre usar estas constantes — nunca URL hardcoded.
///
/// Espelho de `mobile/src/api/api-url.ts`. Path params com [ApiUrls.withParams].
abstract final class ApiUrls {
  // PUBLIC — /auth e /register
  static const authLogin = '/auth/login';
  static const authLoginVerifyToken = '/auth/verifyTokenId';
  static const registerFan = '/register/fan';
  static const registerArtist = '/register/artist';

  // AUTHENTICATED — /api/v1/*
  static const profile = '/api/v1/profile';
  static const profileByUid = '/api/v1/profile/:userUID';
  static const profileMyPosts = '/api/v1/profile/posts';
  static const profileUserPosts = '/api/v1/profile/:userUID/posts';
  static const profileView = '/api/v1/profiles/:handle/overview';
  static const profileSocial = '/api/v1/profiles/:handle/social';
  static const profileFanScore = '/api/v1/profiles/:handle/fan-score';
  static const profileMemberships = '/api/v1/profiles/:handle/memberships';
  static const profilesOverview = '/api/v1/profiles/:handle/overview';
  static const profilesFanScore = '/api/v1/profiles/:handle/fan-score';
  static const subscriptions = '/api/v1/subscriptions';
  static const subscriptionCheck = '/api/v1/subscriptions/:artistUid/check';
  static const subscriptionCancel = '/api/v1/subscriptions/:artistUid';
  static const notificationPreferences = '/api/v1/notifications/preferences';
  static const notifications = '/api/v1/notifications';
  static const notificationDeviceTokens = '/api/v1/notifications/device-tokens';
  static const meReferral = '/api/v1/me/referral';
  static const meWallet = '/api/v1/me/wallet';
  static const meWalletCheckout = '/api/v1/me/wallet/checkout';
  static const meEarnings = '/api/v1/me/earnings';
  static const meEarningsWithdrawals = '/api/v1/me/earnings/withdrawals';
  static const meMediaUploads = '/api/v1/me/media/uploads';
  static const meWs = '/api/v1/me/ws';
  static const jamCoinPacks = '/api/v1/jam-coin-packs';
  static const communityPosts = '/api/v1/community/posts';
  static const artistFollow = '/api/v1/artist/:artistUid/follow';
  static const follows = '/api/v1/follows';
  static const artistFanclub = '/api/v1/artist/:artistUid/fanclub';
  static const artistFanclubModerators =
      '/api/v1/artist/:artistUid/fanclub/moderators';
  static const artistFanclubModerator =
      '/api/v1/artist/:artistUid/fanclub/moderators/:userUid';
  static const artistFanclubModeratorRequests =
      '/api/v1/artist/:artistUid/fanclub/moderator-requests';
  static const artistFanclubModeratorRequestApprove =
      '/api/v1/artist/:artistUid/fanclub/moderator-requests/:requestId/approve';
  static const artistFanclubModeratorRequestReject =
      '/api/v1/artist/:artistUid/fanclub/moderator-requests/:requestId/reject';
  static const searchArtists = '/api/v1/search/artists';
  static const searchArtistRankings = '/api/v1/search/artists/rankings';
  static const blocks = '/api/v1/blocks';
  static const blockUser = '/api/v1/blocks/:userUid';
  static const hiddenPosts = '/api/v1/hidden-posts';
  static const hiddenPost = '/api/v1/hidden-posts/:postId';
  static const savedPosts = '/api/v1/saved-posts';
  static const savedPost = '/api/v1/saved-posts/:postId';
  static const homeFeed = '/api/v1/home';
  static const postCreate = '/api/v1/post';
  static const postUpdate = '/api/v1/post/update/:id';
  static const postDelete = '/api/v1/post/:id';
  static const postGet = '/api/v1/post/:id';
  static const postListUser = '/api/v1/profile/posts';
  static const postComments = '/api/v1/posts/:postId/comments';
  static const postVote = '/api/v1/posts/:postId/vote';
  static const commentDelete = '/api/v1/comments/:commentId';
  static const commentUpdate = '/api/v1/comments/:commentId';
  static const commentVote = '/api/v1/comments/:commentId/vote';
  static const reportCreate = '/api/v1/reports';
  static const fanLetters = '/api/v1/fan-letters';
  static const fanLettersMine = '/api/v1/fan-letters/mine';
  static const fanLettersArtist = '/api/v1/fan-letters/artist/:artistId';
  static const fanLettersMonetization = '/api/v1/fan-letters/monetization';
  static const artistFanclubStrikes =
      '/api/v1/artist/:artistUid/fanclub/strikes';
  static const artistFanclubExpulsions =
      '/api/v1/artist/:artistUid/fanclub/expulsions';
  static const artistFanclubAppeals =
      '/api/v1/artist/:artistUid/fanclub/appeals';
  static const artistFanclubAppealApprove =
      '/api/v1/artist/:artistUid/fanclub/appeals/:appealId/approve';
  static const artistFanclubAppealReject =
      '/api/v1/artist/:artistUid/fanclub/appeals/:appealId/reject';
  static const meFanclubModeration = '/api/v1/me/fanclub-moderation';
  static const meFanclubContestations = '/api/v1/me/fanclub-contestations';
  static const artistAnalyticsInsights =
      '/api/v1/artist/:artistUid/analytics/insights';
  static const artistAnalyticsAudience =
      '/api/v1/artist/:artistUid/analytics/audience';

  /// Alias legado do Expo (`FOLLOWS`).
  static const fanClubs = follows;

  /// Substitui `:param` no path. Ex.: `withParams(profileByUid, {'userUID': uid})`.
  static String withParams(String template, Map<String, String> params) {
    var path = template;
    for (final entry in params.entries) {
      path = path.replaceAll(':${entry.key}', Uri.encodeComponent(entry.value));
    }
    return path;
  }
}
