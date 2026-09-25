import 'package:crowdfans/components/fan_club/fan_club_expelled_banner.dart';
import 'package:crowdfans/components/fan_club/fan_club_moderation_warning_banner.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CF-229 expelled banner: título, motivo e CTA preto', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: FanClubExpelledBanner(
            reason: cfTempMockExpulsionReason,
            onDefend: () {},
          ),
        ),
      ),
    );

    expect(find.text('Você foi expulso deste fã clube'), findsOneWidget);
    expect(find.textContaining('ataques recorrentes'), findsOneWidget);
    expect(find.text('Defender por que voltar'), findsOneWidget);
    expect(find.text('Você foi expulso deste fã-clube'), findsNothing);
  });

  testWidgets('CF-230 warning banner: título e chances do print', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: FanClubModerationWarningBanner(
            reason: cfTempMockStrikeReason,
            remainingChances: 2,
          ),
        ),
      ),
    );

    expect(
      find.text('Você recebeu um aviso neste fã clube'),
      findsOneWidget,
    );
    expect(find.textContaining('provocações repetidas'), findsOneWidget);
    expect(
      find.text('Você ainda tem 2 chances para ajustar seu comportamento.'),
      findsOneWidget,
    );
    expect(find.text('Aviso de moderação'), findsNothing);
  });
}
