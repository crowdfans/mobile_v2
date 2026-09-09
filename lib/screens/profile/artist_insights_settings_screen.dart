import 'package:crowdfans/components/profile/analytics_bar_chart.dart';
import 'package:crowdfans/components/profile/analytics_filter_chip.dart';
import 'package:crowdfans/components/profile/analytics_metric_card.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/artist_analytics_service.dart';
import 'package:crowdfans/state/auth_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const _periods = [
  ('7d', '7d'),
  ('30d', '30d'),
  ('90d', '90d'),
];

const _contentTypes = [
  ('all', 'Tudo'),
  ('posts', 'Posts'),
  ('fanClub', 'Fã clube'),
];

/// Insights do artista autenticado.
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

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final data = _data;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            ProfileScreenHeader(title: 'Insights', onBack: handleBack),
            Expanded(
              child: _loading && data == null
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final item in _periods)
                              AnalyticsFilterChip(
                                label: item.$2,
                                active: _period == item.$1,
                                onTap: () {
                                  setState(() => _period = item.$1);
                                  handleLoad();
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final item in _contentTypes)
                              AnalyticsFilterChip(
                                label: item.$2,
                                active: _contentType == item.$1,
                                onTap: () {
                                  setState(() => _contentType = item.$1);
                                  handleLoad();
                                },
                              ),
                          ],
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
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              for (final card in data.summaryCards)
                                SizedBox(
                                  width:
                                      (MediaQuery.sizeOf(context).width - 42) /
                                      2,
                                  child: AnalyticsMetricCard(card: card),
                                ),
                            ],
                          ),
                          if (data.chart != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              data.chart!.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            AnalyticsBarChart(chart: data.chart!),
                          ],
                          const SizedBox(height: 16),
                          Text(
                            'Origem das interações',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          for (final row in data.breakdown) ...[
                            AnalyticsMetricCard(
                              fullWidth: true,
                              card: ArtistAnalyticsMetricCard(
                                id: row.label,
                                label: row.label,
                                value: row.value,
                                format: '',
                                helper: row.helper,
                              ),
                            ),
                            const SizedBox(height: 10),
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
