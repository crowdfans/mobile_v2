import 'package:crowdfans/components/profile/moderation_hub_card.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Hub Fã Clube: moderação + contestações (CF-163).
class ModerationSettingsScreen extends StatelessWidget {
  const ModerationSettingsScreen({super.key});

  void handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(Pages.profileSettings);
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
              onBack: () => handleBack(context),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 8, bottom: 24),
                children: [
                  ModerationHubCard(
                    title: 'Moderação',
                    subtitle:
                        'Veja os fã clubes em que você é moderador.',
                    onTap: () => context.push(Pages.profileModerationList),
                  ),
                  ModerationHubCard(
                    title: 'Suas Contestações',
                    subtitle:
                        'Acompanhe seus pedidos de retorno e banimentos recebidos.',
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
