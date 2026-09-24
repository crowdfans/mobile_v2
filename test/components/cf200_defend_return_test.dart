import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/fan_club/fan_club_defend_return_field.dart';
import 'package:crowdfans/components/fan_club/fan_club_defend_return_reason_card.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'CF-200: motivo separado; Enviar desabilitado até 24 caracteres',
    (tester) async {
      final controller = TextEditingController();
      var canSubmit = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: StatefulBuilder(
            builder: (context, setState) {
              canSubmit = controller.text.trim().characters.length >=
                  FanClubDefendReturnField.minChars;
              return Scaffold(
                body: Column(
                  children: [
                    const FanClubDefendReturnReasonCard(
                      reason: 'Quebra das regras de convivência.',
                    ),
                    FanClubDefendReturnField(
                      controller: controller,
                      onChanged: (_) => setState(() {}),
                    ),
                    AppButton(
                      label: 'Enviar defesa',
                      variant: AppButtonVariant.dark,
                      disabled: !canSubmit,
                      onPressed: () {},
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Motivo da expulsão'), findsOneWidget);
      expect(find.textContaining('Quebra das regras'), findsOneWidget);
      expect(find.text('Mínimo de 24 caracteres.'), findsOneWidget);
      expect(find.text('0/420'), findsOneWidget);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );

      await tester.enterText(
        find.byType(TextField),
        'a' * FanClubDefendReturnField.minChars,
      );
      await tester.pump();

      expect(find.text('24/420'), findsOneWidget);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNotNull,
      );
    },
  );
}
