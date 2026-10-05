import 'package:crowdfans/components/fan_club/fan_club_compose_artist.dart';
import 'package:crowdfans/services/follow_service.dart';
import 'package:crowdfans/services/subscription_service.dart';

/// Une assinaturas ativas e follows para o seletor Novo post → Fã Clube (CF-237).
///
/// Assinaturas entram primeiro; follows só preenchem artistas ainda ausentes
/// (e trazem [FanClubComposeArtist.avatarUrl]).
List<FanClubComposeArtist> mergeFanClubComposeCandidates({
  required List<Subscription> subscriptions,
  required List<ArtistFollow> follows,
}) {
  final merged = <String, FanClubComposeArtist>{};
  for (final row in subscriptions.where((item) => item.isActive)) {
    final uid = row.artistUid.trim();
    if (uid.isEmpty) {
      continue;
    }
    merged[uid] = FanClubComposeArtist(
      id: uid,
      name: row.artistName.trim().isEmpty ? 'Artista' : row.artistName.trim(),
    );
  }
  for (final follow in follows) {
    final uid = follow.artistUid.trim();
    if (uid.isEmpty) {
      continue;
    }
    merged.putIfAbsent(
      uid,
      () => FanClubComposeArtist(
        id: uid,
        name: follow.artistName.trim().isEmpty
            ? 'Artista'
            : follow.artistName.trim(),
        avatarUrl: follow.avatarUrl,
      ),
    );
  }
  return merged.values.toList();
}
