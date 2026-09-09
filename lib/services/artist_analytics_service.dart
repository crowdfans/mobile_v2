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
      final text = value % 1 == 0
          ? value.toInt().toString()
          : value.toStringAsFixed(1).replaceAll('.', ',');
      return '$text%';
    }
    return formatCompactPtBr(value);
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

/// Destaque numérico no rodapé do gráfico.
class ArtistAnalyticsChartStat {
  const ArtistAnalyticsChartStat({
    required this.value,
    required this.label,
    this.format = '',
  });

  final num value;
  final String label;
  final String format;

  String get formattedValue {
    if (format == 'percent' || label.toLowerCase().contains('engajamento')) {
      final text = value % 1 == 0
          ? value.toInt().toString()
          : value.toStringAsFixed(1).replaceAll('.', ',');
      return '$text%';
    }
    return formatCompactPtBr(value);
  }

  factory ArtistAnalyticsChartStat.fromJson(Object? json) {
    final map = (json as Map?)?.cast<String, dynamic>() ?? {};
    return ArtistAnalyticsChartStat(
      value: map['value'] as num? ?? 0,
      label: map['label']?.toString() ?? '',
      format: map['format']?.toString() ?? '',
    );
  }
}

/// Série de barras/linha dos gráficos de analytics.
class ArtistAnalyticsChart {
  const ArtistAnalyticsChart({
    required this.title,
    required this.subtitle,
    required this.labels,
    required this.series,
    required this.trendPercent,
    this.primaryStat,
    this.secondaryStat,
  });

  final String title;
  final String subtitle;
  final List<String> labels;
  final List<num> series;
  final num trendPercent;
  final ArtistAnalyticsChartStat? primaryStat;
  final ArtistAnalyticsChartStat? secondaryStat;

  String get trendBadge {
    final sign = trendPercent >= 0 ? '+' : '';
    final text = trendPercent % 1 == 0
        ? trendPercent.toInt().toString()
        : trendPercent.toStringAsFixed(0);
    return '$sign$text%';
  }

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
      primaryStat: map['primaryStat'] == null
          ? null
          : ArtistAnalyticsChartStat.fromJson(map['primaryStat']),
      secondaryStat: map['secondaryStat'] == null
          ? null
          : ArtistAnalyticsChartStat.fromJson(map['secondaryStat']),
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

/// Item de distribuição (FanScore, gênero, região…).
class ArtistAnalyticsDistributionItem {
  const ArtistAnalyticsDistributionItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final num value;
  final ColorValue color;
}

/// Cor embutida sem depender de Flutter no serviço.
class ColorValue {
  const ColorValue(this.value);
  final int value;
}

/// Linha de progresso (cidades).
class ArtistAnalyticsProgressRow {
  const ArtistAnalyticsProgressRow({
    required this.label,
    required this.value,
    this.maxValue = 100,
  });

  final String label;
  final num value;
  final num maxValue;
}

/// Audiência lifetime e crescimento.
class ArtistAudience {
  const ArtistAudience({
    required this.period,
    this.lifetimeAudienceTotal = 0,
    this.summaryCards = const [],
    this.growthChart,
    this.fanscoreDistribution = const [],
    this.genderDistribution = const [],
    this.ageDistribution = const [],
    this.regionDistribution = const [],
    this.cityActivityRows = const [],
    this.topCities = const [],
  });

  final String period;
  final num lifetimeAudienceTotal;
  final List<ArtistAnalyticsMetricCard> summaryCards;
  final ArtistAnalyticsChart? growthChart;
  final List<ArtistAnalyticsDistributionItem> fanscoreDistribution;
  final List<ArtistAnalyticsDistributionItem> genderDistribution;
  final List<ArtistAnalyticsDistributionItem> ageDistribution;
  final List<ArtistAnalyticsDistributionItem> regionDistribution;
  final List<ArtistAnalyticsProgressRow> cityActivityRows;
  final List<ArtistAnalyticsDistributionItem> topCities;

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
      fanscoreDistribution: _parseDistribution(map['fanscoreDistribution']),
      genderDistribution: _parseDistribution(map['genderDistribution']),
      ageDistribution: _parseDistribution(map['ageDistribution']),
      regionDistribution: _parseDistribution(map['regionDistribution']),
      cityActivityRows: _parseProgressRows(map['cityActivityRows']),
      topCities: _parseDistribution(map['topCities'] ?? map['topStates']),
    );
  }
}

List<ArtistAnalyticsProgressRow> _parseProgressRows(Object? raw) {
  final list = raw as List? ?? const [];
  return [
    for (final item in list)
      ArtistAnalyticsProgressRow(
        label: _asMap(item)['label']?.toString() ?? '',
        value: _asMap(item)['value'] as num? ?? 0,
        maxValue: _asMap(item)['maxValue'] as num? ?? 100,
      ),
  ];
}

List<ArtistAnalyticsDistributionItem> _parseDistribution(Object? raw) {
  final list = raw as List? ?? const [];
  return [
    for (final item in list)
      ArtistAnalyticsDistributionItem(
        label: _asMap(item)['label']?.toString() ?? '',
        value: _asMap(item)['value'] as num? ?? 0,
        color: ColorValue(
          int.tryParse(
                _asMap(item)['color']?.toString().replaceFirst('#', '0xFF') ??
                    '',
              ) ??
              0xFF7E49FF,
        ),
      ),
  ];
}

Map<String, dynamic> _asMap(Object? value) {
  return (value as Map?)?.cast<String, dynamic>() ?? const {};
}

/// Formata números grandes no padrão dos prints (ex.: 18,4 mil).
String formatCompactPtBr(num value) {
  final absolute = value.abs();
  if (absolute >= 1000000) {
    final millions = absolute / 1000000;
    final text = millions >= 10
        ? millions.toStringAsFixed(0)
        : millions.toStringAsFixed(1).replaceAll('.', ',');
    return '${value < 0 ? '-' : ''}$text mi';
  }
  if (absolute >= 1000) {
    final thousands = absolute / 1000;
    final text = thousands >= 10
        ? thousands.toStringAsFixed(0)
        : thousands.toStringAsFixed(1).replaceAll('.', ',');
    return '${value < 0 ? '-' : ''}$text mil';
  }
  if (value % 1 == 0) {
    return value.toInt().toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
  }
  return value.toStringAsFixed(1).replaceAll('.', ',');
}

/// Analytics do artista (`/api/v1/artist/:artistUid/analytics/*`).
abstract final class ArtistAnalyticsService {
  /// Tipos de conteúdo suportados de verdade pela API.
  static const apiContentTypes = {'all', 'posts', 'fanClub'};

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
