/// Perfil do usuário autenticado (`GET /api/v1/profile`).
class Profile {
  const Profile({
    required this.userUid,
    required this.displayName,
    required this.name,
    required this.description,
    required this.photoUrl,
    required this.isArtist,
  });

  final String userUid;
  final String displayName;
  final String name;
  final String description;
  final String photoUrl;
  final bool isArtist;

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      userUid: json['userUid'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      photoUrl: json['photoUrl'] as String? ?? '',
      isArtist: json['isArtist'] == true,
    );
  }
}
