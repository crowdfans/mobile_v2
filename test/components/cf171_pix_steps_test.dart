import 'package:crowdfans/components/profile/wallet_pix_code_panel.dart';
import 'package:crowdfans/components/profile/wallet_pix_step_row.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CF-171: etapas numeradas grandes e sem texto técnico', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: WalletPixCodePanel(
            pixCode: '00020126...',
            onCopy: () {},
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

    final numberStyle = tester.widget<Text>(find.text('01')).style!;
    expect(numberStyle.fontSize, greaterThanOrEqualTo(24));
    expect(numberStyle.fontWeight, FontWeight.w900);
  });

  testWidgets('CF-171: numeração sem chip/caixa de fundo', (tester) async {
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
}
