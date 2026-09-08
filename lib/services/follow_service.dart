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
  static Future<ArtistFollow> followArtist(String artistUid) {
    return HttpService.request(
      ApiUrls.withParams(ApiUrls.artistFollow, {'artistUid': artistUid}),
      method: Method.post,
      parse: (json) =>
          ArtistFollow.fromJson(json as Map<String, dynamic>? ?? {}),
    );
  }

  static Future<void> unfollowArtist(String artistUid) async {
    await HttpService.request<dynamic>(
      ApiUrls.withParams(ApiUrls.artistFollow, {'artistUid': artistUid}),
      method: Method.delete,
    );
  }

  static Future<bool> checkFollow(String artistUid) async {
    final data = await HttpService.request<Map<String, dynamic>>(
      ApiUrls.withParams(ApiUrls.artistFollow, {'artistUid': artistUid}),
      parse: (json) => (json as Map?)?.cast<String, dynamic>() ?? {},
    );
    return data['isFollowing'] == true;
  }

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
