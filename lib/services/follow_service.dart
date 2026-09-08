import 'package:crowdfans/api/api_urls.dart';
import 'package:crowdfans/services/http_service.dart';

class ArtistFollow {
  const ArtistFollow({
    required this.artistUid,
    required this.artistName,
    required this.avatarUrl,
    required this.isFollowing,
  });

  final String artistUid;
  final String artistName;
  final String avatarUrl;
  final bool isFollowing;

  factory ArtistFollow.fromJson(Map<String, dynamic> json) {
    return ArtistFollow(
      artistUid: json['artistUid'] as String? ?? '',
      artistName: json['artistName'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? '',
      isFollowing: json['isFollowing'] == true,
    );
  }
}

/// Seguir / listar fan clubs (`FOLLOWS` + `ARTIST_FOLLOW`).
abstract final class FollowService {
  static Future<List<ArtistFollow>> listFollows() {
    return HttpService.request(
      ApiUrls.follows,
      parse: (json) {
        final list = json as List? ?? const [];
        return [
          for (final item in list)
            ArtistFollow.fromJson(item as Map<String, dynamic>),
        ];
      },
    );
  }
}
