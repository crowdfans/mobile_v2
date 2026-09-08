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
    this.stats = const ProfileStats(),
  });

  final String userUid;
  final String displayName;
  final String name;
  final String description;
  final String photoUrl;
  final bool isArtist;
  final ProfileStats stats;

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      userUid: json['userUid'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      photoUrl: json['photoUrl'] as String? ?? '',
      isArtist: json['isArtist'] == true,
      stats: ProfileStats.fromJson(json['stats'] as Map<String, dynamic>?),
    );
  }
}
