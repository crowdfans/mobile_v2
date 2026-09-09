import 'package:crowdfans/components/profile/analytics_breakdown_section.dart';
import 'package:crowdfans/components/profile/analytics_content_tabs.dart';
import 'package:crowdfans/components/profile/analytics_line_chart_card.dart';
import 'package:crowdfans/components/profile/analytics_metric_card.dart';
import 'package:crowdfans/components/profile/analytics_period_chips.dart';
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

const _contentTypes = [
  ('all', 'Tudo'),
  ('posts', 'Posts'),
  ('fanClub', 'Fã clube'),
  ('meetGreet', 'M&G'),
  ('lives', 'Lives'),
  ('fanLetters', 'Cartas de fã'),
];

/// Insights do artista autenticado (CF-115).
class ArtistInsightsSettingsScreen extends ConsumerStatefulWidget {
  const ArtistInsightsSettingsScreen({super.key});

  @override
  ConsumerState<ArtistInsightsSettingsScreen> createState() =>
      _ArtistInsightsSettingsScreenState();
}

class _ArtistInsightsSettingsScreenState
    extends ConsumerState<ArtistInsightsSettingsScreen> {
  var _period = '30d';
  var _contentType = 'all';
  ArtistInsights? _data;
  var _loading = true;
  String? _error;

  bool get _apiSupported =>
      ArtistAnalyticsService.apiContentTypes.contains(_contentType);

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
        _data = null;
      });
      return;
    }
    if (!_apiSupported) {
      setState(() {
        _loading = false;
        _error = null;
        _data = null;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final insights = await ArtistAnalyticsService.getArtistInsights(
        uid,
        period: _period,
        contentType: _contentType,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _data = insights;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _data = null;
        _loading = false;
        _error = 'Não foi possível carregar os insights.';
      });
    }
  }

  String get _unsupportedMessage {
    final label = _contentTypes
        .firstWhere(
          (item) => item.$1 == _contentType,
          orElse: () => (_contentType, _contentType),
        )
        .$2;
    return 'Métricas detalhadas de $label ainda não estão disponíveis na API. Use Tudo, Posts ou Fã clube.';
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final data = _data;
    final width = MediaQuery.sizeOf(context).width;
    final cardWidth = (width - 42) / 2;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            ProfileScreenHeader(title: 'Insights', onBack: handleBack),
            Expanded(
              child: _loading && data == null && _apiSupported
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
                        const SizedBox(height: 14),
                        AnalyticsContentTabs(
                          tabs: _contentTypes,
                          selectedId: _contentType,
                          onSelected: (id) {
                            setState(() => _contentType = id);
                            handleLoad();
                          },
                        ),
                        const SizedBox(height: 16),
                        if (!_apiSupported)
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: colors.surfaceAlt,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                _unsupportedMessage,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: colors.textSecondary,
                                ),
                              ),
                            ),
                          )
                        else if (_error != null)
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: colors.textSecondary),
                          )
                        else if (data != null) ...[
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
                          if (data.chart != null) ...[
                            const SizedBox(height: 14),
                            AnalyticsLineChartCard(chart: data.chart!),
                          ],
                          if (_contentType == 'all' &&
                              data.breakdown.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            AnalyticsBreakdownSection(
                              title: 'Que tipo de ação puxou resultado',
                              subtitle:
                                  'Visão consolidada da performance dos produtos da Crowd Fans no período.',
                              rows: data.breakdown,
                            ),
                          ],
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
