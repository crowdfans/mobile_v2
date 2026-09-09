/// Artista escolhido para publicar no fã clube.
class FanClubComposeArtist {
  const FanClubComposeArtist({
    required this.id,
    required this.name,
    this.avatarUrl = '',
  });

  final String id;
  final String name;
  final String avatarUrl;
}
