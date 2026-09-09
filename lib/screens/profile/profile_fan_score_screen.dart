import 'package:crowdfans/components/profile/fan_score_settings_entry.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/components/profile/profile_state.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/fan_score.dart';
import 'package:crowdfans/services/profile_service.dart';
import 'package:crowdfans/state/auth_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Fan Score do viewer nas settings.
class ProfileFanScoreScreen extends ConsumerStatefulWidget {
  const ProfileFanScoreScreen({super.key});

  @override
  ConsumerState<ProfileFanScoreScreen> createState() =>
      _ProfileFanScoreScreenState();
}

class _ProfileFanScoreScreenState extends ConsumerState<ProfileFanScoreScreen> {
  FanScoreData? _data;
  var _loading = true;
  String? _error;
  String? _expandedId;

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
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      var profile = ref.read(authSessionProvider).profile;
      profile ??= await ProfileService.getMyProfile();
      final handle = profile.name.trim().isNotEmpty
          ? profile.name
          : profile.displayName;
      final data = await ProfileService.getFanScore(handle);
      if (!mounted) {
        return;
      }
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = 'Não foi possível carregar o Fan Score.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final entries = _data?.entries ?? const <FanScoreEntry>[];
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            ProfileScreenHeader(title: 'Fan Score', onBack: handleBack),
            Expanded(
              child: _loading
                  ? const ProfileState(loading: true)
                  : _error != null
                  ? ProfileState(
                      title: 'Fan Score indisponível',
                      message: _error,
                      actionLabel: 'Tentar novamente',
                      onAction: handleLoad,
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: colors.border),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sua conexão com cada artista',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: colors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 7),
                                Text(
                                  'O Fan Score considera participação no Fã Clube, comentários, votos, Fan Letters, lives e memberships. Um novo ciclo começa a cada mês.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 19 / 13,
                                    color: colors.textSecondary,
                                  ),
                                ),
                                if (((_data?.cycleDetails?.periodLabel ?? '')
                                            .isNotEmpty) ||
                                    ((_data?.cycleDetails?.cycleLabel ?? '')
                                        .isNotEmpty)) ...[
                                  const SizedBox(height: 7),
                                  Text(
                                    (_data!.cycleDetails!.periodLabel ?? '')
                                            .isNotEmpty
                                        ? _data!.cycleDetails!.periodLabel!
                                        : _data!.cycleDetails!.cycleLabel!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: colors.primaryStrong,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (entries.isEmpty)
                          const ProfileState(
                            title: 'Sem pontuação neste ciclo',
                            message: 'Participe das comunidades dos seus artistas para construir seu Fan Score.',
                          )
                        else
                          for (final entry in entries) ...[
                            FanScoreSettingsEntry(
                              entry: entry,
                              expanded: _expandedId == entry.artistId,
                              onToggle: () {
                                setState(() {
                                  _expandedId = _expandedId == entry.artistId
                                      ? null
                                      : entry.artistId;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: colors.surfaceAlt,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Como evoluir',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: colors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Interaja de forma autêntica: acompanhe os posts, participe das conversas, envie Fan Letters e compareça a lives. Cada artista possui uma pontuação independente.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 20 / 13,
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
