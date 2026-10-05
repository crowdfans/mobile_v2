/// Contadores do perfil autenticado.
class ProfileStats {
  const ProfileStats({
    this.postsCount = 0,
    this.cartasCount = 0,
    this.artistasCount = 0,
  });

  final int postsCount;
  final int cartasCount;
  final int artistasCount;

  factory ProfileStats.fromJson(Map<String, dynamic>? json) {
    final map = json ?? {};
    return ProfileStats(
      postsCount: (map['postsCount'] as num?)?.toInt() ?? 0,
      cartasCount: (map['cartasCount'] as num?)?.toInt() ?? 0,
      artistasCount: (map['artistasCount'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Perfil do usuário autenticado (`GET /api/v1/profile`).
class Profile {
  const Profile({
    required this.userUid,
    required this.displayName,
    required this.name,
    required this.description,
    required this.photoUrl,
    required this.isArtist,
    this.phone = '',
    this.phoneVerified = false,
    this.stats = const ProfileStats(),
    this.location = '',
    this.trackTitle = '',
    this.playlistSubtitle = '',
    this.monthlyListeners = '',
    this.genre = '',
    this.openSpotifyAlbum = '',
    this.spotifyProfileUrl = '',
    this.previewUrl = '',
    this.previewReady = false,
    this.instagramHandle = '',
    this.youtubeHandle = '',
  });

  final String userUid;
  final String displayName;
  final String name;
  final String description;
  final String photoUrl;
  final bool isArtist;

  /// E.164 do login (`user_logins.phone`), quando sincronizado (CF-271).
  final String phone;
  final bool phoneVerified;
  final ProfileStats stats;

  /// CF-269 — aba Sobre (artista). Vazios em fã / sem cadastro.
  final String location;
  final String trackTitle;
  final String playlistSubtitle;
  final String monthlyListeners;
  final String genre;
  final String openSpotifyAlbum;
  final String spotifyProfileUrl;
  final String previewUrl;
  final bool previewReady;
  final String instagramHandle;
  final String youtubeHandle;

  Profile copyWith({
    String? userUid,
    String? displayName,
    String? name,
    String? description,
    String? photoUrl,
    bool? isArtist,
    String? phone,
    bool? phoneVerified,
    ProfileStats? stats,
    String? location,
    String? trackTitle,
    String? playlistSubtitle,
    String? monthlyListeners,
    String? genre,
    String? openSpotifyAlbum,
    String? spotifyProfileUrl,
    String? previewUrl,
    bool? previewReady,
    String? instagramHandle,
    String? youtubeHandle,
  }) {
    return Profile(
      userUid: userUid ?? this.userUid,
      displayName: displayName ?? this.displayName,
      name: name ?? this.name,
      description: description ?? this.description,
      photoUrl: photoUrl ?? this.photoUrl,
      isArtist: isArtist ?? this.isArtist,
      phone: phone ?? this.phone,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      stats: stats ?? this.stats,
      location: location ?? this.location,
      trackTitle: trackTitle ?? this.trackTitle,
      playlistSubtitle: playlistSubtitle ?? this.playlistSubtitle,
      monthlyListeners: monthlyListeners ?? this.monthlyListeners,
      genre: genre ?? this.genre,
      openSpotifyAlbum: openSpotifyAlbum ?? this.openSpotifyAlbum,
      spotifyProfileUrl: spotifyProfileUrl ?? this.spotifyProfileUrl,
      previewUrl: previewUrl ?? this.previewUrl,
      previewReady: previewReady ?? this.previewReady,
      instagramHandle: instagramHandle ?? this.instagramHandle,
      youtubeHandle: youtubeHandle ?? this.youtubeHandle,
    );
  }

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      userUid: json['userUid'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      photoUrl: json['photoUrl'] as String? ?? '',
      isArtist: json['isArtist'] == true,
      phone: json['phone'] as String? ?? '',
      phoneVerified: json['phoneVerified'] == true,
      stats: ProfileStats.fromJson(json['stats'] as Map<String, dynamic>?),
      location: json['location'] as String? ?? '',
      trackTitle: json['trackTitle'] as String? ?? '',
      playlistSubtitle: json['playlistSubtitle'] as String? ?? '',
      monthlyListeners: json['monthlyListeners'] as String? ?? '',
      genre: json['genre'] as String? ?? '',
      openSpotifyAlbum: json['openSpotifyAlbum'] as String? ?? '',
      spotifyProfileUrl: json['spotifyProfileUrl'] as String? ?? '',
      previewUrl: json['previewUrl'] as String? ?? '',
      previewReady: json['previewReady'] == true,
      instagramHandle: json['instagramHandle'] as String? ?? '',
      youtubeHandle: json['youtubeHandle'] as String? ?? '',
    );
  }
}
