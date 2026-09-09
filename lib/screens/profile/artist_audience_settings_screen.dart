import 'package:crowdfans/components/profile/analytics_audience_charts.dart';
import 'package:crowdfans/components/profile/analytics_line_chart_card.dart';
import 'package:crowdfans/components/profile/analytics_metric_card.dart';
import 'package:crowdfans/components/profile/analytics_period_chips.dart';
import 'package:crowdfans/components/profile/artist_audience_presentation.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/artist_analytics_service.dart';
import 'package:crowdfans/state/auth_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const _periods = [
  ('7d', '7 dias'),
  ('30d', '30 dias'),
  ('90d', '90 dias'),
];

/// Público / audiência do artista autenticado (CF-116).
class ArtistAudienceSettingsScreen extends ConsumerStatefulWidget {
  const ArtistAudienceSettingsScreen({super.key});

  @override
  ConsumerState<ArtistAudienceSettingsScreen> createState() =>
      _ArtistAudienceSettingsScreenState();
}

class _ArtistAudienceSettingsScreenState
    extends ConsumerState<ArtistAudienceSettingsScreen> {
  var _period = '30d';
  ArtistAudience? _data;
  var _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    handleLoad();
  }

  void handleBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(Pages.profileSettings);
  }

  Future<void> handleLoad() async {
    final uid = ref.read(authSessionProvider).profile?.userUid ?? '';
    if (uid.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Perfil de artista não encontrado.';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final audience = await ArtistAnalyticsService.getArtistAudience(
        uid,
        period: _period,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _data = audience;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _data = null;
        _loading = false;
        _error = 'Não foi possível carregar a audiência.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final data = _data;
    final width = MediaQuery.sizeOf(context).width;
    final cardWidth = (width - 42) / 2;
    final pieWidth = (width - 42) / 2;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            ProfileScreenHeader(title: 'Público', onBack: handleBack),
            Expanded(
              child: _loading && data == null
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                      children: [
                        AnalyticsPeriodChips(
                          periods: _periods,
                          selectedId: _period,
                          onSelected: (id) {
                            setState(() => _period = id);
                            handleLoad();
                          },
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: colors.textSecondary),
                          ),
                        ],
                        if (data != null) ...[
                          const SizedBox(height: 14),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: colors.border),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total de fãs',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    formatCompactPtBr(
                                      data.lifetimeAudienceTotal,
                                    ),
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Audiência lifetime (engajadores + membros + assinantes)',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              for (final card in data.summaryCards)
                                SizedBox(
                                  width: cardWidth,
                                  child: AnalyticsMetricCard(card: card),
                                ),
                            ],
                          ),
                          if (data.growthChart != null) ...[
                            const SizedBox(height: 14),
                            AnalyticsLineChartCard(chart: data.growthChart!),
                          ],
                          const SizedBox(height: 14),
                          AnalyticsSectionCard(
                            title: 'Distribuição por FanScore',
                            subtitle:
                                'Como a base está dividida entre ultimate fãs, engajados e audiência casual',
                            child: AnalyticsDistributionBar(
                              items: ArtistAudiencePresentation.orPresentation(
                                data.fanscoreDistribution,
                                ArtistAudiencePresentation.fanscore,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          AnalyticsSectionCard(
                            title: 'Cidades com mais atividade',
                            subtitle:
                                'Onde sua base responde com maior constância hoje',
                            child: AnalyticsHorizontalBarList(
                              items: ArtistAudiencePresentation.orProgress(
                                data.cityActivityRows,
                                ArtistAudiencePresentation.cityActivity,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: pieWidth,
                                child: AnalyticsPieChartCard(
                                  title: 'Faixa etária',
                                  subtitle: 'Base ativa',
                                  items:
                                      ArtistAudiencePresentation.orPresentation(
                                    data.ageDistribution,
                                    ArtistAudiencePresentation.age,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: pieWidth,
                                child: AnalyticsPieChartCard(
                                  title: 'Gênero',
                                  subtitle: 'Base ativa',
                                  items:
                                      ArtistAudiencePresentation.orPresentation(
                                    data.genderDistribution,
                                    ArtistAudiencePresentation.gender,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          AnalyticsSectionCard(
                            title: 'Concentração regional',
                            subtitle:
                                'Visão territorial da base para decisões de campanha e agenda',
                            child: Column(
                              children: [
                                AnalyticsDistributionBar(
                                  items:
                                      ArtistAudiencePresentation.orPresentation(
                                    data.regionDistribution,
                                    ArtistAudiencePresentation.regions,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                AnalyticsLocationChips(
                                  items:
                                      ArtistAudiencePresentation.orPresentation(
                                    data.topCities,
                                    ArtistAudiencePresentation.topCities,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
