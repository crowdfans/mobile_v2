import 'package:crowdfans/services/artist_analytics_service.dart';

/// Dados demográficos de apresentação (prints) quando a API ainda não envia.
///
/// A API atual retorna lifetime/summary/growth. FanScore/cidades/regiões/idade/
/// gênero ficam nestes seeds até o backend expor os campos.
abstract final class ArtistAudiencePresentation {
  static const fanscore = [
    ArtistAnalyticsDistributionItem(
      label: 'Ultimate Fan',
      value: 9,
      color: ColorValue(0xFF2C0B6A),
    ),
    ArtistAnalyticsDistributionItem(
      label: 'Super Fan',
      value: 14,
      color: ColorValue(0xFF48169C),
    ),
    ArtistAnalyticsDistributionItem(
      label: 'Engajado',
      value: 26,
      color: ColorValue(0xFF681EE3),
    ),
    ArtistAnalyticsDistributionItem(
      label: 'Casual',
      value: 24,
      color: ColorValue(0xFF7E49FF),
    ),
    ArtistAnalyticsDistributionItem(
      label: 'Dormente',
      value: 16,
      color: ColorValue(0xFFA285FF),
    ),
    ArtistAnalyticsDistributionItem(
      label: 'Curioso',
      value: 11,
      color: ColorValue(0xFFC1B1FF),
    ),
  ];

  static const age = [
    ArtistAnalyticsDistributionItem(
      label: '13-17',
      value: 11,
      color: ColorValue(0xFF2C0B6A),
    ),
    ArtistAnalyticsDistributionItem(
      label: '18-24',
      value: 39,
      color: ColorValue(0xFF5718BF),
    ),
    ArtistAnalyticsDistributionItem(
      label: '25-34',
      value: 28,
      color: ColorValue(0xFF7E49FF),
    ),
    ArtistAnalyticsDistributionItem(
      label: '35-44',
      value: 14,
      color: ColorValue(0xFFA285FF),
    ),
    ArtistAnalyticsDistributionItem(
      label: '45+',
      value: 8,
      color: ColorValue(0xFFC1B1FF),
    ),
  ];

  static const gender = [
    ArtistAnalyticsDistributionItem(
      label: 'Mulheres',
      value: 62,
      color: ColorValue(0xFF5718BF),
    ),
    ArtistAnalyticsDistributionItem(
      label: 'Homens',
      value: 31,
      color: ColorValue(0xFFA285FF),
    ),
    ArtistAnalyticsDistributionItem(
      label: 'Não informado',
      value: 7,
      color: ColorValue(0xFFDAD4FF),
    ),
  ];

  static const regions = [
    ArtistAnalyticsDistributionItem(
      label: 'Sudeste',
      value: 47,
      color: ColorValue(0xFF2C0B6A),
    ),
    ArtistAnalyticsDistributionItem(
      label: 'Nordeste',
      value: 21,
      color: ColorValue(0xFF5718BF),
    ),
    ArtistAnalyticsDistributionItem(
      label: 'Sul',
      value: 13,
      color: ColorValue(0xFF7E49FF),
    ),
    ArtistAnalyticsDistributionItem(
      label: 'Centro-Oeste',
      value: 11,
      color: ColorValue(0xFFA285FF),
    ),
    ArtistAnalyticsDistributionItem(
      label: 'Norte',
      value: 8,
      color: ColorValue(0xFFC1B1FF),
    ),
  ];

  static const topCities = [
    ArtistAnalyticsDistributionItem(
      label: 'São Paulo',
      value: 22,
      color: ColorValue(0xFF7E49FF),
    ),
    ArtistAnalyticsDistributionItem(
      label: 'Rio de Janeiro',
      value: 13,
      color: ColorValue(0xFF7E49FF),
    ),
    ArtistAnalyticsDistributionItem(
      label: 'Belo Horizonte',
      value: 9,
      color: ColorValue(0xFF7E49FF),
    ),
  ];

  static const cityActivity = [
    ArtistAnalyticsProgressRow(label: 'São Paulo', value: 96, maxValue: 100),
    ArtistAnalyticsProgressRow(label: 'Rio de Janeiro', value: 84, maxValue: 100),
    ArtistAnalyticsProgressRow(label: 'Belo Horizonte', value: 71, maxValue: 100),
    ArtistAnalyticsProgressRow(label: 'Salvador', value: 62, maxValue: 100),
    ArtistAnalyticsProgressRow(label: 'Curitiba', value: 54, maxValue: 100),
  ];

  static List<ArtistAnalyticsDistributionItem> orPresentation(
    List<ArtistAnalyticsDistributionItem> fromApi,
    List<ArtistAnalyticsDistributionItem> fallback,
  ) {
    return fromApi.isNotEmpty ? fromApi : fallback;
  }

  static List<ArtistAnalyticsProgressRow> orProgress(
    List<ArtistAnalyticsProgressRow> fromApi,
    List<ArtistAnalyticsProgressRow> fallback,
  ) {
    return fromApi.isNotEmpty ? fromApi : fallback;
  }
}
