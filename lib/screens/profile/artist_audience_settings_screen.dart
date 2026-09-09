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

/// Público / audiência do artista autenticado.
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
                                    data.lifetimeAudienceTotal
                                        .round()
                                        .toString(),
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
                                  width:
                                      (MediaQuery.sizeOf(context).width - 42) /
                                      2,
                                  child: AnalyticsMetricCard(card: card),
                                ),
                            ],
                          ),
                          if (data.growthChart != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              data.growthChart!.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            AnalyticsBarChart(chart: data.growthChart!),
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
