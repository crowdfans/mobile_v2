import 'package:crowdfans/components/profile/membership_balance_pill.dart';
import 'package:crowdfans/components/profile/membership_filter_chip.dart';
import 'package:crowdfans/components/profile/membership_pro_teaser.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CF-167: header pill, banner CTA, sem RevenueCat', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: Column(
            children: [
              const MembershipBalancePill(balance: '2.684'),
              MembershipProTeaser(onPressed: () {}),
              MembershipFilterChip(
                label: 'Todos',
                selected: true,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('2.684'), findsOneWidget);
    expect(find.text('420 Jam Coins'), findsNothing);
    expect(find.text('Assinar agora mesmo'), findsOneWidget);
    expect(find.text('Todos'), findsOneWidget);
    expect(find.textContaining('RevenueCat'), findsNothing);
    expect(find.text('CrowdFans Pro'), findsNothing);
    expect(find.text('Recarregar Jam Coins'), findsNothing);
  });
}
