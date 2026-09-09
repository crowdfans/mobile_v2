import 'package:crowdfans/components/profile/moderation_hub_card.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Hub de moderação: clubs que modero + minhas contestações.
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
              title: 'Moderação do Fã Clube',
              onBack: () => handleBack(context),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                children: [
                  ModerationHubCard(
                    title: 'Moderação',
                    subtitle:
                        'Clubs que você possui ou modera — strikes, expulsões e apelações.',
                    onTap: () => context.push(Pages.profileModerationList),
                  ),
                  const SizedBox(height: 12),
                  ModerationHubCard(
                    title: 'Suas contestações',
                    subtitle:
                        'Expulsões recebidas e status das apelações enviadas.',
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
