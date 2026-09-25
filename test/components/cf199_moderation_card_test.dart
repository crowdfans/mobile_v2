import 'package:crowdfans/components/fan_club/fan_club_moderation_card.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'CF-199: bloco lavanda, defesa em texto corrido, Aceitar/Recusar fora',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: FanClubModerationCard(
              title: 'Anna Lu',
              subtitle: 'fan/annalu',
              statusLabel: 'Defesa enviada',
              body:
                  'Eu entendi o motivo da expulsão e quero voltar de forma respeitosa.',
              onApprove: () {},
              onReject: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Defesa enviada'), findsOneWidget);
      expect(find.textContaining('quero voltar'), findsOneWidget);
      expect(find.text('Aceitar'), findsOneWidget);
      expect(find.text('Recusar'), findsOneWidget);

      final bodyBox = tester.widgetList<DecoratedBox>(find.byType(DecoratedBox));
      final hasLavender = bodyBox.any((box) {
        final decoration = box.decoration;
        return decoration is BoxDecoration &&
            decoration.color == AppPalette.purple50;
      });
      expect(hasLavender, isTrue);

      // Sem caixa aninhada cinza (surfaceAlt) em volta da defesa.
      final hasNestedAlt = bodyBox.any((box) {
        final decoration = box.decoration;
        return decoration is BoxDecoration &&
            decoration.color == AppPalette.platinum100 &&
            (decoration.borderRadius != null);
      });
      expect(hasNestedAlt, isFalse);
    },
  );
}
