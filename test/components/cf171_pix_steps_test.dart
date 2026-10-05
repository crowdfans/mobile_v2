import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/profile/wallet_pix_code_panel.dart';
import 'package:crowdfans/components/profile/wallet_pix_step_row.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/utils/wallet_user_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // --- green ---
  testWidgets(
    'CF-171 green: etapas 01/02/03 grandes, código e CTA escuro Copiar',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: Column(
              children: [
                WalletPixCodePanel(
                  pixCode: Cf171PixCheckoutMock.pixCopyPaste,
                  onCopy: () {},
                ),
                AppButton(
                  label: 'Copiar Código PIX',
                  variant: AppButtonVariant.dark,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(WalletPixStepRow), findsNWidgets(3));
      expect(find.text('01'), findsOneWidget);
      expect(find.text('02'), findsOneWidget);
      expect(find.text('03'), findsOneWidget);
      expect(find.text('Copie o código Pix:'), findsOneWidget);
      expect(find.textContaining('Sandbox'), findsNothing);
      expect(find.textContaining('RevenueCat'), findsNothing);
      expect(find.textContaining('CF-54'), findsNothing);
      expect(find.text('Copiar Código PIX'), findsOneWidget);

      final numberStyle = tester.widget<Text>(find.text('01')).style!;
      expect(numberStyle.fontSize, greaterThanOrEqualTo(24));
      expect(numberStyle.fontWeight, FontWeight.w900);

      expect(
        tester
            .widget<FilledButton>(find.byType(FilledButton))
            .style!
            .backgroundColor!
            .resolve({}),
        AppPalette.platinum900,
      );

      expect(kUseCfTempMocks && kUseCf171PixCheckoutMocks, isTrue);
      final mock = Cf171PixCheckoutMock.pending(packId: 'cf170-240');
      expect(mock.status, 'pending');
      expect(mock.pixCopyPaste, isNotEmpty);
      expect(mock.message, isNull);
    },
  );

  test('CF-171 green: validade no horário de Brasília', () {
    final label = walletPixValidityLabel(
      DateTime.utc(2026, 10, 5, 17, 33), // 14:33 BRT → +30min = 15:03
    );
    expect(
      label,
      'Este código é válido até hoje, 15:03 - Horário de Brasília.',
    );
  });

  // --- red ---
  testWidgets('CF-171 red: numeração sem chip/caixa de fundo', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: const Scaffold(
          body: WalletPixStepRow(number: '01', text: 'Passo'),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(DecoratedBox), findsNothing);
    expect(find.byType(Container), findsNothing);
  });

  test('CF-171 red: filtro omite sandbox / RevenueCat / CF-54', () {
    expect(
      walletUserFacingMessage(
        'Sandbox credit applied. Produção usa RevenueCat (CF-54)',
      ),
      isNull,
    );
    expect(walletUserFacingMessage('via RevenueCat'), isNull);
    expect(walletUserFacingMessage('ref CF-54'), isNull);
    expect(walletUserFacingMessage(''), isNull);
  });

  test('CF-171 red: mock nunca devolve paid sem código (pula etapas)', () {
    final mock = Cf171PixCheckoutMock.pending(packId: 'x', coins: 0);
    expect(mock.status, isNot(equals('paid')));
    expect(mock.pixCopyPaste?.trim(), isNotEmpty);
  });

  // --- edge ---
  testWidgets(
    'CF-171 edge: código PIX longo truncado com ellipsis',
    (tester) async {
      final longCode = 'A' * 240;
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: WalletPixCodePanel(pixCode: longCode, onCopy: () {}),
          ),
        ),
      );
      await tester.pump();

      final codeText = tester.widget<Text>(
        find.descendant(
          of: find.byType(DecoratedBox),
          matching: find.byType(Text),
        ).first,
      );
      expect(codeText.maxLines, 3);
      expect(codeText.overflow, TextOverflow.ellipsis);
      expect(find.text('01'), findsOneWidget);
    },
  );

  test('CF-171 edge: validade com zero padding e meio-dia BRT', () {
    final label = walletPixValidityLabel(
      DateTime.utc(2026, 10, 5, 14, 40), // 11:40 BRT → 12:10
    );
    expect(
      label,
      'Este código é válido até hoje, 12:10 - Horário de Brasília.',
    );
    expect(Cf171PixCheckoutMock.pixCopyPaste.startsWith('000201'), isTrue);
  });
}
