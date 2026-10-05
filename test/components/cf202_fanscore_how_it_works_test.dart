import 'package:crowdfans/components/profile/fan_score_how_it_works_card.dart';
import 'package:crowdfans/components/profile/fan_score_how_it_works_factors.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/screens/profile/fan_score_how_it_works_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CF-202: cards de ciclo, ranking e benefício Top 10', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: const FanScoreHowItWorksScreen(
          cycleEndLabel: 'segunda-feira, 31/08/2026 às 23:59',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Como funciona o FanScore'), findsOneWidget);
    expect(find.text('Um score diferente para cada artista'), findsOneWidget);
    expect(
      find.textContaining(
        'Seu FanScore mede o quanto você participa dentro da plataforma',
      ),
      findsOneWidget,
    );
    expect(find.text('Ranking entre fãs'), findsOneWidget);
    expect(
      find.textContaining('A badge aparece só quando você está no top 100'),
      findsOneWidget,
    );
    expect(find.text('BENEFÍCIO IMPORTANTE'), findsOneWidget);
    expect(
      find.text('Top 10 tem prioridade na fila do meet and greet'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Se você ficar entre os 10 maiores fãs'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Membership e doações carregam mais peso'),
      findsOneWidget,
    );
    expect(
      find.textContaining('segunda-feira, 31/08/2026 às 23:59'),
      findsOneWidget,
    );
    expect(find.byType(FanScoreHowItWorksCard), findsNWidgets(4));
    expect(find.text('O que entra na conta'), findsOneWidget);
    expect(find.byType(FanScoreHowItWorksFactors), findsOneWidget);
    expect(find.text(cfTempMockFanScoreHowItWorksFactorsBody), findsOneWidget);
  });

  testWidgets('CF-202: sem cycleEndLabel usa fallback mensal', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: const FanScoreHowItWorksScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('fim do período mensal'), findsOneWidget);
  });
}
