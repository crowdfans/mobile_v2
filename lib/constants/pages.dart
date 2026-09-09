/// Rotas do app — única fonte de verdade (espelho de `page_list.ts`).
abstract final class Pages {
  static const presentation = '/onboarding/presentation';
  static const loginFan = '/login/fan';
  static const loginArtist = '/login/artist';

  static const registerFan = '/register/fan';
  static const registerFanOtp = '/register/fan/otp';
  static const registerFanEmail = '/register/fan/email';
  static const registerFanPassword = '/register/fan/password';
  static const registerFanName = '/register/fan/name';
  static const registerFanBirthdate = '/register/fan/birthdate';
  static const registerFanUsername = '/register/fan/username';
  static const registerFanProfile = '/register/fan/profile';
  static const registerFanTerms = '/register/fan/terms';
  static const registerFanSuccess = '/register/fan/success';

  static const registerArtist = '/register/artist';
  static const registerArtistOtp = '/register/artist/otp';
  static const registerArtistEmail = '/register/artist/email';
  static const registerArtistData = '/register/artist/data';

  static const home = '/feed';
  static const clubs = '/clubs';
  static const explore = '/explore';
  static const me = '/me';

  static const fanProfile = '/profile/:fanHandle';
  static const fanScorePublic = '/profile/fan-score/:fanHandle';
  static const artistProfile = '/artists/:artistId';
  static const comments = '/comments/:postId';

  /// Perfil público do artista com seeds opcionais de nome/avatar.
  static String artistProfileOf(
    String artistId, {
    String? name,
    String? avatarUrl,
  }) {
    return _withArtistQuery(
      '/artists/${Uri.encodeComponent(artistId)}',
      artistId: artistId,
      name: name,
      avatarUrl: avatarUrl,
    );
  }
  static const fanClubCommunity = '/fan-clubs/community/:artistId';
  static const fanClubCompose = '/fan-clubs/compose';
  static const fanClubAbout = '/fan-clubs/about';
  static const fanClubModerators = '/fan-clubs/moderators';
  static const fanClubModeration = '/fan-clubs/moderation';
  static const fanClubRules = '/fan-clubs/rules';
  static const searchRanking = '/explore/ranking';
  static const report = '/report';
  static const fanLetterCompose = '/fan-letter/compose';
  static const fanLetterGallery = '/fan-letter/gallery';
  static const notifications = '/notifications';
  static const createPost = '/post/create';
  static const myPosts = '/post/mine';

  /// ⛔ Live / Meet — buracos Espelho Expo até existirem no produto.
  static const liveUnavailable = '/live';
  static const meetUnavailable = '/meet';

  /// Edição de post (`CreatePostScreen?postId=`).
  static String createPostEdit(String postId) =>
      '$createPost?postId=${Uri.encodeQueryComponent(postId)}';

  /// Perfil público de fã. O handle `fan/username` vai em um único segmento.
  static String fanProfileOf(String handle) =>
      fanProfile.replaceAll(':fanHandle', Uri.encodeComponent(handle.trim()));

  /// Fan Score público do handle informado.
  static String fanScorePublicOf(String handle) => fanScorePublic.replaceAll(
    ':fanHandle',
    Uri.encodeComponent(handle.trim()),
  );

  /// Artistas seguidos; `handle` opcional para outro perfil.
  static String profileArtistsOf({String? handle}) {
    final value = handle?.trim() ?? '';
    if (value.isEmpty) {
      return profileArtists;
    }
    return Uri(
      path: profileArtists,
      queryParameters: {'handle': value},
    ).toString();
  }

  /// Comunidade do artista (`FanClubCommunityScreen`).
  static String fanClubCommunityOf(
    String artistId, {
    String? name,
    String? avatarUrl,
  }) {
    return _withArtistQuery(
      '/fan-clubs/community/${Uri.encodeComponent(artistId)}',
      artistId: artistId,
      name: name,
      avatarUrl: avatarUrl,
    );
  }

  static String fanLetterComposeOf({
    String? artistId,
    String? name,
    String? avatarUrl,
  }) {
    return _withArtistQuery(
      fanLetterCompose,
      artistId: artistId,
      name: name,
      avatarUrl: avatarUrl,
    );
  }

  /// Pagamento de pacote Jam Coins.
  static String profileWalletPaymentOf({
    required String packId,
    String? productId,
    String? label,
    int? coins,
    int? priceCents,
  }) {
    return Uri(
      path: profileWalletPayment,
      queryParameters: {
        'packId': packId,
        if ((productId ?? '').trim().isNotEmpty) 'productId': productId!.trim(),
        if ((label ?? '').trim().isNotEmpty) 'label': label!.trim(),
        if (coins != null) 'coins': '$coins',
        if (priceCents != null) 'priceCents': '$priceCents',
      },
    ).toString();
  }
  static String fanClubComposeOf({
    String? artistId,
    String? name,
    String? avatarUrl,
  }) {
    return _withArtistQuery(
      fanClubCompose,
      artistId: artistId,
      name: name,
      avatarUrl: avatarUrl,
    );
  }

  static String fanClubAboutOf({
    required String artistId,
    String? name,
    String? avatarUrl,
  }) {
    return _withArtistQuery(
      fanClubAbout,
      artistId: artistId,
      name: name,
      avatarUrl: avatarUrl,
    );
  }

  static String fanClubModeratorsOf({required String artistId, String? name}) {
    return _withArtistQuery(fanClubModerators, artistId: artistId, name: name);
  }

  static String fanClubModerationOf({required String artistId, String? name}) {
    return _withArtistQuery(fanClubModeration, artistId: artistId, name: name);
  }

  static String _withArtistQuery(
    String path, {
    String? artistId,
    String? name,
    String? avatarUrl,
  }) {
    final id = artistId?.trim() ?? '';
    if (id.isEmpty) {
      return path;
    }
    return Uri(
      path: path,
      queryParameters: {
        'artistId': id,
        if ((name ?? '').trim().isNotEmpty) 'name': name!.trim(),
        if ((avatarUrl ?? '').trim().isNotEmpty) 'avatarUrl': avatarUrl!.trim(),
      },
    ).toString();
  }

  static const profileAccount = '/me/settings/account';
  static const profileAppearance = '/me/settings/appearance';
  static const profileArtists = '/me/artists';
  static const profileFanScore = '/me/settings/fan-score';
  static const profileInformation = '/me/settings/information';
  static const profileMemberships = '/me/settings/memberships';
  static const profilePro = '/me/settings/pro';
  static const profileWallet = '/me/settings/wallet';
  static const profileWalletRecharge = '/me/settings/wallet/recharge';
  static const profileWalletPayment = '/me/settings/wallet/payment';
  static const profileEarnings = '/me/settings/earnings';
  static const profileNotifications = '/me/settings/notifications';
  static const profileSecurity = '/me/settings/security';
  static const profileReferral = '/me/settings/referral';
  static const profileSettings = '/me/settings';
  static const profileBlockedUsers = '/me/settings/blocked';
  static const profileHiddenPosts = '/me/settings/hidden-posts';
  static const profileMemories = '/me/settings/memories';
  static const profileModeration = '/me/settings/moderation';
  static const profileModerationList = '/me/settings/moderation-list';
  static const profileContestations = '/me/settings/contestations';
  static const profileArtistInsights = '/me/settings/artist-insights';
  static const profileArtistAudience = '/me/settings/artist-audience';
  static const profileArtistFanClub = '/me/settings/artist-fan-club';

  /// Prefixos que não exigem sessão (espelho do Expo `AppRootAuthGate`).
  /// Prefixos que não exigem sessão (espelho do Expo `AppRootAuthGate`).
  static const publicPrefixes = ['/onboarding', '/login', '/register'];

  static const _expoAliases = <String, String>{
    '/pages/demo/DemoScreen': home,
    '/pages/feed': home,
    '/pages/clubs': clubs,
    '/pages/explore': explore,
    '/pages/me': me,
    '/pages/login/fan/FanLoginScreen': loginFan,
    '/pages/login/artist/ArtistLoginScreen': loginArtist,
    '/pages/onboarding/presentation/PresentationScreen': presentation,
    '/pages/search/SearchRankingScreen': searchRanking,
    '/pages/report/ReportScreen': report,
    '/pages/fan-letter/FanLetterComposeScreen': fanLetterCompose,
    '/pages/fan-letter/FanLetterGalleryScreen': fanLetterGallery,
    '/pages/notifications/NotificationsScreen': notifications,
    '/pages/post/CreatePostScreen': createPost,
    '/pages/post/MyPostsScreen': myPosts,
    '/pages/fan-clubs/FanClubComposeScreen': fanClubCompose,
    '/pages/fan-clubs/FanClubAboutScreen': fanClubAbout,
    '/pages/fan-clubs/FanClubModeratorsScreen': fanClubModerators,
    '/pages/fan-clubs/FanClubModerationScreen': fanClubModeration,
    '/pages/fan-clubs/FanClubRulesScreen': fanClubRules,
    '/pages/profile/settings/ProfileAccountScreen': profileAccount,
    '/pages/profile/settings/ProfileAppearanceScreen': profileAppearance,
    '/pages/profile/ProfileArtistsScreen': profileArtists,
    '/pages/profile/settings/ProfileFanScoreScreen': profileFanScore,
    '/pages/profile/settings/ProfileInformationScreen': profileInformation,
    '/pages/profile/settings/ProfileMembershipsScreen': profileMemberships,
    '/pages/profile/settings/ProfileProScreen': profilePro,
    '/pages/profile/settings/ProfileWalletScreen': profileWallet,
    '/pages/profile/settings/ProfileWalletRechargeScreen':
        profileWalletRecharge,
    '/pages/profile/settings/ProfileWalletPaymentScreen': profileWalletPayment,
    '/pages/profile/settings/ProfileEarningsScreen': profileEarnings,
    '/pages/profile/settings/ProfileNotificationsScreen': profileNotifications,
    '/pages/profile/settings/ProfileSecurityScreen': profileSecurity,
    '/pages/profile/settings/ProfileReferralScreen': profileReferral,
    '/pages/profile/settings/ProfileSettingsScreen': profileSettings,
    '/pages/profile/settings/BlockedUsersSettingsScreen': profileBlockedUsers,
    '/pages/profile/settings/HiddenPostsSettingsScreen': profileHiddenPosts,
    '/pages/profile/settings/ProfileMemoriesScreen': profileMemories,
    '/pages/profile/settings/ModerationSettingsScreen': profileModeration,
    '/pages/profile/settings/FanClubModerationListScreen':
        profileModerationList,
    '/pages/profile/settings/FanClubContestationListScreen':
        profileContestations,
    '/pages/profile/settings/ArtistInsightsSettingsScreen':
        profileArtistInsights,
    '/pages/profile/settings/ArtistAudienceSettingsScreen':
        profileArtistAudience,
    '/pages/profile/settings/ArtistFanClubSettingsScreen': profileArtistFanClub,
    '/pages/register/artist/RegisterArtistScreen': registerArtist,
    '/pages/register/artist/RegisterArtistDataScreen': registerArtistData,
    '/pages/register/artist/RegisterArtistEmailScreen': registerArtistEmail,
    '/pages/register/artist/RegisterArtistOtpScreen': registerArtistOtp,
    '/pages/register/fan/RegisterFanScreen': registerFan,
    '/pages/register/fan/RegisterFanBirthdateScreen': registerFanBirthdate,
    '/pages/register/fan/RegisterFanEmailScreen': registerFanEmail,
    '/pages/register/fan/RegisterFanNameScreen': registerFanName,
    '/pages/register/fan/RegisterFanOtpScreen': registerFanOtp,
    '/pages/register/fan/RegisterFanPasswordScreen': registerFanPassword,
    '/pages/register/fan/RegisterFanProfileScreen': registerFanProfile,
    '/pages/register/fan/RegisterFanUsernameScreen': registerFanUsername,
    '/pages/register/fan/RegisterFanTermsScreen': registerFanTerms,
    '/pages/register/fan/RegisterFanSuccessScreen': registerFanSuccess,
  };

  /// Converte deep link Expo (`/pages/...` ou `mobile://...`) para rota Flutter.
  static String fromIncomingLocation(String location) {
    var path = location;
    if (path.startsWith('mobile:')) {
      final uri = Uri.parse(path);
      path = uri.path.isEmpty ? '/${uri.host}' : uri.path;
      if (uri.query.isNotEmpty) {
        path = '$path?${uri.query}';
      }
    }
    if (!path.startsWith('/')) {
      path = '/$path';
    }
    final withoutQuery = path.split('?').first;
    final mapped = _expoAliases[withoutQuery];
    if (mapped != null) {
      final q = path.contains('?') ? path.substring(path.indexOf('?')) : '';
      return '$mapped$q';
    }
    return _mapExpoParamPath(withoutQuery) ?? path;
  }

  static String? _mapExpoParamPath(String path) {
    final profile = RegExp(r'^/pages/profile/([^/]+)$').firstMatch(path);
    if (profile != null) {
      return fanProfile.replaceAll(':fanHandle', profile.group(1)!);
    }
    final score = RegExp(r'^/pages/profile/fan-score/([^/]+)$')
        .firstMatch(path);
    if (score != null) {
      return fanScorePublic.replaceAll(':fanHandle', score.group(1)!);
    }
    final artist = RegExp(r'^/pages/artists/([^/]+)$').firstMatch(path);
    if (artist != null) {
      return artistProfile.replaceAll(':artistId', artist.group(1)!);
    }
    final artistShort = RegExp(r'^/artists/([^/]+)').firstMatch(path);
    if (artistShort != null) {
      return artistProfile.replaceAll(':artistId', artistShort.group(1)!);
    }
    final commentsMatch = RegExp(r'^/pages/comments/([^/]+)$').firstMatch(path);
    if (commentsMatch != null) {
      return comments.replaceAll(':postId', commentsMatch.group(1)!);
    }
    final commentsShort = RegExp(r'^/comments/([^/]+)').firstMatch(path);
    if (commentsShort != null) {
      return comments.replaceAll(':postId', commentsShort.group(1)!);
    }
    final community = RegExp(r'^/pages/fan-clubs/community/([^/]+)$')
        .firstMatch(path);
    if (community != null) {
      return fanClubCommunity.replaceAll(':artistId', community.group(1)!);
    }
    final communityShort =
        RegExp(r'^/fan-clubs/community/([^/]+)').firstMatch(path);
    if (communityShort != null) {
      return fanClubCommunity.replaceAll(':artistId', communityShort.group(1)!);
    }
    return null;
  }
}
