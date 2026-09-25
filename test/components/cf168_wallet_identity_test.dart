import 'package:crowdfans/components/profile/wallet_home_balance_card.dart';
import 'package:crowdfans/components/profile/wallet_membership_banner.dart';
import 'package:crowdfans/components/profile/wallet_promo_banner.dart';
import 'package:crowdfans/components/profile/wallet_scan_earn_row.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
                WalletPromoBanner(countdown: '02:15:00', onRecharge: () {}),
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
    expect(find.text('Recarregar agora'), findsOneWidget);
    expect(find.text('Assinar agora mesmo'), findsOneWidget);
    expect(find.text('Escaneie e ganhe'), findsOneWidget);
    expect(find.text('+120'), findsOneWidget);
    expect(find.byIcon(Icons.qr_code_scanner), findsNothing);
    expect(find.textContaining('Oferta termina'), findsNothing);
    expect(find.byType(Image), findsNWidgets(4));
  });
}
