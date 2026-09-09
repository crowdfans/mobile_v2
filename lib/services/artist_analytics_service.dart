import 'package:crowdfans/api/api_urls.dart';
import 'package:crowdfans/services/http_service.dart';

/// Cartão de métrica dos insights/audiência.
class ArtistAnalyticsMetricCard {
  const ArtistAnalyticsMetricCard({
    required this.id,
    required this.label,
    required this.value,
    required this.format,
    required this.helper,
  });

  final String id;
  final String label;
  final num value;
  final String format;
  final String helper;

  String get formattedValue {
    if (format == 'percent') {
      return '$value%';
    }
    return value.round().toString();
  }

  factory ArtistAnalyticsMetricCard.fromJson(Object? json) {
    final map = (json as Map?)?.cast<String, dynamic>() ?? {};
    return ArtistAnalyticsMetricCard(
      id: map['id']?.toString() ?? '',
      label: map['label']?.toString() ?? '',
      value: map['value'] as num? ?? 0,
      format: map['format']?.toString() ?? '',
      helper: map['helper']?.toString() ?? '',
    );
  }
}

/// Série de barras dos gráficos de analytics.
class ArtistAnalyticsChart {
  const ArtistAnalyticsChart({
    required this.title,
    required this.subtitle,
    required this.labels,
    required this.series,
    required this.trendPercent,
  });

  final String title;
  final String subtitle;
  final List<String> labels;
  final List<num> series;
  final num trendPercent;

  factory ArtistAnalyticsChart.fromJson(Object? json) {
    final map = (json as Map?)?.cast<String, dynamic>() ?? {};
    return ArtistAnalyticsChart(
      title: map['title']?.toString() ?? '',
      subtitle: map['subtitle']?.toString() ?? '',
      labels: [
        for (final item in map['labels'] as List? ?? const []) item.toString(),
      ],
      series: [
        for (final item in map['series'] as List? ?? const [])
          item is num ? item : num.tryParse(item.toString()) ?? 0,
      ],
      trendPercent: map['trendPercent'] as num? ?? 0,
    );
  }
}

/// Linha de origem das interações.
class ArtistAnalyticsBreakdownRow {
  const ArtistAnalyticsBreakdownRow({
    required this.label,
    required this.value,
    required this.helper,
  });

  final String label;
  final num value;
  final String helper;

  factory ArtistAnalyticsBreakdownRow.fromJson(Object? json) {
    final map = (json as Map?)?.cast<String, dynamic>() ?? {};
    return ArtistAnalyticsBreakdownRow(
      label: map['label']?.toString() ?? '',
      value: map['value'] as num? ?? 0,
      helper: map['helper']?.toString() ?? '',
    );
  }
}

/// Insights de posts / fã clube.
class ArtistInsights {
  const ArtistInsights({
    required this.period,
    required this.contentType,
    this.summaryCards = const [],
    this.chart,
    this.breakdown = const [],
  });

  final String period;
  final String contentType;
  final List<ArtistAnalyticsMetricCard> summaryCards;
  final ArtistAnalyticsChart? chart;
  final List<ArtistAnalyticsBreakdownRow> breakdown;

  factory ArtistInsights.fromJson(Object? json) {
    final map = (json as Map?)?.cast<String, dynamic>() ?? {};
    return ArtistInsights(
      period: map['period']?.toString() ?? '',
      contentType: map['contentType']?.toString() ?? '',
      summaryCards: [
        for (final item in map['summaryCards'] as List? ?? const [])
          ArtistAnalyticsMetricCard.fromJson(item),
      ],
      chart: map['chart'] == null
          ? null
          : ArtistAnalyticsChart.fromJson(map['chart']),
      breakdown: [
        for (final item in map['breakdown'] as List? ?? const [])
          ArtistAnalyticsBreakdownRow.fromJson(item),
      ],
    );
  }
}

/// Audiência lifetime e crescimento.
class ArtistAudience {
  const ArtistAudience({
    required this.period,
    this.lifetimeAudienceTotal = 0,
    this.summaryCards = const [],
    this.growthChart,
  });

  final String period;
  final num lifetimeAudienceTotal;
  final List<ArtistAnalyticsMetricCard> summaryCards;
  final ArtistAnalyticsChart? growthChart;

  factory ArtistAudience.fromJson(Object? json) {
    final map = (json as Map?)?.cast<String, dynamic>() ?? {};
    return ArtistAudience(
      period: map['period']?.toString() ?? '',
      lifetimeAudienceTotal: map['lifetimeAudienceTotal'] as num? ?? 0,
      summaryCards: [
        for (final item in map['summaryCards'] as List? ?? const [])
          ArtistAnalyticsMetricCard.fromJson(item),
      ],
      growthChart: map['growthChart'] == null
          ? null
          : ArtistAnalyticsChart.fromJson(map['growthChart']),
    );
  }
}

/// Analytics do artista (`/api/v1/artist/:artistUid/analytics/*`).
abstract final class ArtistAnalyticsService {
  static Future<ArtistInsights> getArtistInsights(
    String artistUid, {
    String period = '30d',
    String contentType = 'all',
  }) {
    final path = ApiUrls.withParams(ApiUrls.artistAnalyticsInsights, {
      'artistUid': artistUid,
    });
    return HttpService.request(
      '$path?period=${Uri.encodeQueryComponent(period)}'
      '&contentType=${Uri.encodeQueryComponent(contentType)}',
      parse: ArtistInsights.fromJson,
    );
  }

  static Future<ArtistAudience> getArtistAudience(
    String artistUid, {
    String period = '30d',
  }) {
    final path = ApiUrls.withParams(ApiUrls.artistAnalyticsAudience, {
      'artistUid': artistUid,
    });
    return HttpService.request(
      '$path?period=${Uri.encodeQueryComponent(period)}',
      parse: ArtistAudience.fromJson,
    );
  }
}
