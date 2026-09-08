import 'package:crowdfans/api/api_urls.dart';
import 'package:crowdfans/services/http_service.dart';

class ArtistSearchItem {
  const ArtistSearchItem({
    required this.id,
    required this.name,
    required this.handle,
    required this.avatarUri,
    required this.memberCount,
    required this.membersLabel,
    this.rank,
    this.rankingValueLabel,
  });

  final String id;
  final String name;
  final String handle;
  final String avatarUri;
  final int memberCount;
  final String membersLabel;
  final int? rank;
  final String? rankingValueLabel;

  factory ArtistSearchItem.fromJson(Map<String, dynamic> json) {
    return ArtistSearchItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      handle: json['handle'] as String? ?? '',
      avatarUri: json['avatarUri'] as String? ?? '',
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
      membersLabel: json['membersLabel'] as String? ?? '',
      rank: (json['rank'] as num?)?.toInt(),
      rankingValueLabel: json['rankingValueLabel'] as String?,
    );
  }
}

class ArtistSearchResponse {
  const ArtistSearchResponse({required this.artists, required this.total});

  final List<ArtistSearchItem> artists;
  final int total;

  factory ArtistSearchResponse.fromJson(Object? json) {
    final map = json as Map<String, dynamic>? ?? {};
    return ArtistSearchResponse(
      artists: [
        for (final item in map['artists'] as List? ?? const [])
          ArtistSearchItem.fromJson(item as Map<String, dynamic>),
      ],
      total: (map['total'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Busca e rankings de artistas.
abstract final class SearchService {
  static Future<ArtistSearchResponse> searchArtists(String query) {
    final params = Uri(queryParameters: {'q': query.trim(), 'limit': '20'});
    return HttpService.request(
      '${ApiUrls.searchArtists}${params.query.isEmpty ? '' : '?${params.query}'}',
      parse: ArtistSearchResponse.fromJson,
    );
  }

  static Future<ArtistSearchResponse> rankArtists(
    String kind, {
    int limit = 100,
  }) {
    final params = Uri(queryParameters: {'kind': kind, 'limit': '$limit'});
    return HttpService.request(
      '${ApiUrls.searchArtistRankings}?${params.query}',
      parse: ArtistSearchResponse.fromJson,
    );
  }
}
