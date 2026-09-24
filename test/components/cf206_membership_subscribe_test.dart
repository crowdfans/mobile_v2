import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/profile/membership_subscribe_artist_summary.dart';
import 'package:crowdfans/components/profile/membership_subscribe_expectations.dart';
import 'package:crowdfans/components/profile/membership_subscribe_terms_checkbox.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'CF-206: Assinar desabilitado sem aceite; preço real no resumo',
    (tester) async {
      var accepted = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Column(
                  children: [
                    const MembershipSubscribeArtistSummary(
                      artistName: 'Banda Uelo',
                      artistHandle: 'bandauelo',
                      pricePerMonth: 100,
                    ),
                    const MembershipSubscribeExpectations(),
                    MembershipSubscribeTermsCheckbox(
                      accepted: accepted,
                      onChanged: (value) => setState(() => accepted = value),
                    ),
                    AppButton(
                      label: 'Assinar',
                      variant: AppButtonVariant.dark,
                      disabled: !accepted,
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

      expect(find.text('100 Jam Coins / mês'), findsOneWidget);
      expect(find.text('240 Jam Coins / mês'), findsNothing);
      expect(find.textContaining('Apoio em primeiro lugar'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(find.byType(FilledButton))
            .onPressed,
        isNull,
      );

      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      expect(
        tester
            .widget<FilledButton>(find.byType(FilledButton))
            .onPressed,
        isNotNull,
      );
    },
  );
}
