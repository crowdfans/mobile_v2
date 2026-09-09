import 'package:crowdfans/components/fan_club/fan_club_rules_section.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Diretrizes estáticas da comunidade (sem API).
class FanClubRulesScreen extends StatelessWidget {
  const FanClubRulesScreen({super.key});

  void handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(Pages.clubs);
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
              title: 'Regras do Fã Clube',
              onBack: () => handleBack(context),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
                children: [
                  Text(
                    'Diretrizes da Comunidade',
                    style: TextStyle(
                      fontSize: 24,
                      height: 1.3,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Na Crowd Fans, a música aproxima pessoas. Este é um espaço para viver a relação entre artistas e fãs de um jeito mais próximo, mais verdadeiro e mais humano.',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.45,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Equipe Crowd Fans',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Feito de fã pra fã.',
                    style: TextStyle(fontSize: 14, color: colors.textTertiary),
                  ),
                  for (var i = 0; i < fanClubRulesSections.length; i++)
                    FanClubRulesSectionView(
                      section: fanClubRulesSections[i],
                      showDivider: i < fanClubRulesSections.length - 1,
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
