import 'package:crowdfans/components/profile/wallet_home_balance_card.dart';
import 'package:crowdfans/components/profile/wallet_membership_banner.dart';
import 'package:crowdfans/components/profile/wallet_promo_banner.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CF-168: moeda dourada e banners com arte', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: ListView(
            children: [
              WalletHomeBalanceCard(balance: '1.250', onRecharge: () {}),
              const SizedBox(height: 12),
              WalletPromoBanner(countdown: '02:15:00', onRecharge: () {}),
              const SizedBox(height: 12),
              WalletMembershipBanner(onSubscribe: () {}),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byIcon(Icons.toll), findsNothing);
    expect(find.text('Recarregar'), findsOneWidget);
    expect(find.byType(Image), findsNWidgets(3));
  });
}
