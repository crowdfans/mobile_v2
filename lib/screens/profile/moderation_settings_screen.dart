import 'package:crowdfans/components/profile/moderation_hub_card.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/fan_club_viewer_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Hub Fã Clube: moderação + contestações (CF-163).
class ModerationSettingsScreen extends StatefulWidget {
  const ModerationSettingsScreen({super.key});

  @override
  State<ModerationSettingsScreen> createState() =>
      _ModerationSettingsScreenState();
}

class _ModerationSettingsScreenState extends State<ModerationSettingsScreen> {
  int? _moderationCount;
  int? _contestationCount;

  @override
  void initState() {
    super.initState();
    handleLoadCounts();
  }

  void handleBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(Pages.profileSettings);
  }

  Future<void> handleLoadCounts() async {
    try {
      final results = await Future.wait([
        FanClubViewerService.listMyModerationCommunities(),
        FanClubViewerService.listMyContestations(),
      ]);
      if (!mounted) {
        return;
      }
      setState(() {
        _moderationCount = results[0].length;
        _contestationCount = results[1].length;
      });
    } catch (_) {
      // Mantém chevron se a contagem falhar; não bloqueia o hub.
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            ProfileScreenHeader(
              title: 'Fã Clube',
              onBack: handleBack,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 8, bottom: 24),
                children: [
                  ModerationHubCard(
                    title: 'Moderação',
                    subtitle:
                        'Veja os fã clubes em que você é moderador.',
                    badgeCount: _moderationCount,
                    onTap: () => context.push(Pages.profileModerationList),
                  ),
                  ModerationHubCard(
                    title: 'Suas Contestações',
                    subtitle:
                        'Acompanhe seus pedidos de retorno e banimentos recebidos.',
                    badgeCount: _contestationCount,
                    onTap: () => context.push(Pages.profileContestations),
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
