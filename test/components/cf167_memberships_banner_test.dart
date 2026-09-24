import 'package:crowdfans/components/profile/membership_balance_banner.dart';
import 'package:crowdfans/components/profile/membership_pro_teaser.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CF-167: saldo compacto e banner sem RevenueCat', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: Column(
            children: [
              const MembershipBalanceBanner(balance: '420'),
              MembershipProTeaser(onPressed: () {}),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('420 Jam Coins'), findsOneWidget);
    expect(find.textContaining('RevenueCat'), findsNothing);
    expect(find.text('CrowdFans Pro'), findsNothing);
    expect(find.byType(Image), findsNWidgets(2));
  });
}
