import 'package:crowdfans/components/profile/membership_balance_pill.dart';
import 'package:crowdfans/components/profile/membership_filter_chip.dart';
import 'package:crowdfans/components/profile/membership_pro_teaser.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

/// CF-167 vs print: saldo compacto no header, banner Membership Fan, sem
/// cartão de carteira / CrowdFans Pro / RevenueCat / Recarregar.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CF-167: header pill + banner CTA + filtros sem RevenueCat', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 56,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Icon(Icons.chevron_left),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/Shapes/star-01.svg',
                            width: 18,
                            height: 18,
                          ),
                          const SizedBox(width: 6),
                          const Text('Meus Memberships'),
                        ],
                      ),
                      const Align(
                        alignment: Alignment.centerRight,
                        child: MembershipBalancePill(balance: '2.684'),
                      ),
                    ],
                  ),
                ),
                MembershipProTeaser(onPressed: () {}),
                const SizedBox(height: 12),
                const Text('Meus Memberships'),
                MembershipFilterChip(
                  label: 'Todos',
                  selected: true,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Meus Memberships'), findsNWidgets(2));
    expect(find.text('2.684'), findsOneWidget);
    expect(find.text('Assinar agora mesmo'), findsOneWidget);
    expect(find.text('Todos'), findsOneWidget);

    expect(find.text('Saldo da carteira'), findsNothing);
    expect(find.text('100 Jam Coins'), findsNothing);
    expect(find.text('420 Jam Coins'), findsNothing);
    expect(find.text('Recarregar Jam Coins'), findsNothing);
    expect(find.text('CrowdFans Pro'), findsNothing);
    expect(find.textContaining('RevenueCat'), findsNothing);

    final teaser = tester.widget<MembershipProTeaser>(
      find.byType(MembershipProTeaser),
    );
    expect(teaser.ctaLabel, 'Assinar agora mesmo');
    expect(MembershipProTeaser.aspectRatio, closeTo(344 / 235, 0.001));
  });
}
