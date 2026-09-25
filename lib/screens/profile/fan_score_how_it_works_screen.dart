import 'package:crowdfans/components/profile/fan_score_how_it_works_card.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Explica regras de ciclo, ranking e benefício Top 10 (CF-202).
class FanScoreHowItWorksScreen extends StatelessWidget {
  const FanScoreHowItWorksScreen({super.key, this.cycleEndLabel});

  /// Rótulo do fim do ciclo vindo do serviço (quando disponível).
  final String? cycleEndLabel;

  void handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    Navigator.of(context).maybePop();
  }

  String cycleFooter() {
    final end = (cycleEndLabel ?? '').trim();
    if (end.isNotEmpty) {
      return 'O ciclo vigente encerra em $end e reseta logo em seguida.';
    }
    // TEMP: copy do print CF-202 quando não há ciclo da API.
    if (CfTempMocks.useFanScoreFixtures && kUseCfTempMocks) {
      return 'O ciclo vigente encerra em ${cfTempMockFanScoreData().cycleDetails!.endLabel!} e reseta logo em seguida.';
    }
    return 'O ciclo vigente encerra no fim do período mensal e reseta logo em seguida.';
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
              title: 'Como funciona o FanScore',
              onBack: () => handleBack(context),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
                children: [
                  FanScoreHowItWorksCard(
                    tone: FanScoreHowItWorksCardTone.purple,
                    title: 'Um score diferente para cada artista',
                    body:
                        'O FanScore mede sua participação com cada artista que você acompanha. '
                        'A pontuação é calculada separadamente por artista e reinicia no começo de cada mês.',
                    footer: cycleFooter(),
                  ),
                  const SizedBox(height: 12),
                  const FanScoreHowItWorksCard(
                    tone: FanScoreHowItWorksCardTone.neutral,
                    title: 'Ranking entre fãs',
                    body:
                        'Além da pontuação individual, mostramos sua posição em relação aos outros fãs do mesmo artista. '
                        'Se você estiver entre os 100 primeiros, aparece um badge. '
                        'Ficar no Top 10 dá prioridade na fila do meet and greet virtual.',
                  ),
                  const SizedBox(height: 12),
                  const FanScoreHowItWorksCard(
                    tone: FanScoreHowItWorksCardTone.benefit,
                    eyebrow: 'Benefício importante',
                    title: 'Top 10 tem prioridade na fila do meet and greet',
                    body:
                        'Manter-se no Top 10 de um artista garante prioridade nas filas de meet and greet virtual '
                        'daquele artista. O benefício depende do ranking do ciclo vigente.',
                  ),
                  const SizedBox(height: 12),
                  const FanScoreHowItWorksCard(
                    tone: FanScoreHowItWorksCardTone.scoring,
                    title: 'Como a pontuação foi pensada',
                    body:
                        'Membership e doações pesam mais na pontuação. '
                        'O status Ultimate Fã é raro e costuma exigir atividade quase diária ao longo do mês.',
                  ),
                  const SizedBox(height: 20),
                  // Print CF-202: seção seguinte abaixo dos cards.
                  Text(
                    'O que entra na conta',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: colors.textSecondary,
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
