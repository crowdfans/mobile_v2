import 'package:crowdfans/components/profile/wallet_home_balance_card.dart';
import 'package:crowdfans/components/profile/wallet_membership_banner.dart';
import 'package:crowdfans/components/profile/wallet_promo_banner.dart';
import 'package:crowdfans/components/profile/wallet_scan_earn_row.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/screens/profile/profile_wallet_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CF-168: formatOfferEndsLabel segue o print Termina em DD/MM HH:MM:SS', () {
    final label = formatOfferEndsLabel(DateTime(2026, 6, 16, 16, 28, 17));
    expect(label, 'Termina em 16/06 16:28:17');
  });

  testWidgets('CF-168: moeda, banners e Escaneie e ganhe', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                WalletHomeBalanceCard(balance: '2.684', onRecharge: () {}),
                const SizedBox(height: 12),
                WalletPromoBanner(
                  countdown: 'Termina em 16/06 16:28:17',
                  onRecharge: () {},
                ),
                const SizedBox(height: 12),
                WalletMembershipBanner(onSubscribe: () {}),
                const SizedBox(height: 12),
                WalletScanEarnRow(onPressed: () {}),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Seu saldo'), findsNothing);
    expect(find.text('Jam Coins'), findsOneWidget);
    expect(find.text('2.684'), findsOneWidget);
    expect(find.text('Recarregar'), findsOneWidget);
    expect(find.text('Termina em 16/06 16:28:17'), findsOneWidget);
    expect(find.text('Recarregar agora'), findsOneWidget);
    expect(find.text('Assinar agora mesmo'), findsOneWidget);
    expect(find.text('Escaneie e ganhe'), findsOneWidget);
    expect(find.text('+120'), findsOneWidget);
    expect(find.byIcon(Icons.qr_code_scanner), findsNothing);
    expect(find.textContaining('Oferta termina'), findsNothing);
    expect(find.textContaining('Convide amigos'), findsNothing);
    expect(find.byType(Image), findsNWidgets(4));

    final yellowPill = tester.widgetList<DecoratedBox>(find.byType(DecoratedBox)).where((box) {
      final decoration = box.decoration;
      return decoration is BoxDecoration &&
          decoration.color == const Color(0xFFFFF0B8) &&
          decoration.borderRadius == BorderRadius.circular(999);
    });
    expect(yellowPill.length, 1);
  });
}
