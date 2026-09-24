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
    this.rankDelta,
    this.trend,
    this.previousRank,
    this.weeksInRanking,
    this.peakRank,
  });

  final String id;
  final String name;
  final String handle;
  final String avatarUri;
  final int memberCount;
  final String membersLabel;
  final int? rank;
  final String? rankingValueLabel;

  /// Delta absoluto de posição (`trendDelta` no backend). Sinal vem de [trend].
  final int? rankDelta;

  /// `up` | `down` | `neutral` | `new` (API `trend`).
  final String? trend;

  /// Posição na janela anterior (`previousRank`).
  final int? previousRank;

  /// Semanas consecutivas no ranking — opcional; ausente → UI mostra "—".
  final int? weeksInRanking;

  /// Melhor posição histórica conhecida — opcional; ausente → UI mostra "—".
  final int? peakRank;

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
      rankDelta: (json['trendDelta'] as num?)?.toInt() ??
          (json['rankDelta'] as num?)?.toInt() ??
          (json['delta'] as num?)?.toInt(),
      trend: (json['trend'] as String?)?.trim(),
      previousRank: (json['previousRank'] as num?)?.toInt(),
      weeksInRanking: (json['weeksInRanking'] as num?)?.toInt(),
      peakRank: (json['peakRank'] as num?)?.toInt() ??
          (json['maxRank'] as num?)?.toInt(),
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
  static Future<ArtistSearchResponse> searchArtists(
    String query, {
    int limit = 30,
  }) {
    final params = Uri(
      queryParameters: {'q': query.trim(), 'limit': '$limit'},
    );
    return HttpService.request(
      '${ApiUrls.searchArtists}${params.query.isEmpty ? '' : '?${params.query}'}',
      parse: ArtistSearchResponse.fromJson,
    );
  }

  static Future<ArtistSearchResponse> rankArtists(
    String kind, {
    int limit = 100,
    int offset = 0,
  }) {
    final params = Uri(
      queryParameters: {
        'kind': kind,
        'limit': '$limit',
        if (offset > 0) 'offset': '$offset',
      },
    );
    return HttpService.request(
      '${ApiUrls.searchArtistRankings}?${params.query}',
      parse: ArtistSearchResponse.fromJson,
    );
  }
}
