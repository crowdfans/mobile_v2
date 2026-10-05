import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/profile/membership_subscribe_artist_summary.dart';
import 'package:crowdfans/components/profile/membership_subscribe_balance_pill.dart';
import 'package:crowdfans/components/profile/membership_subscribe_expectations.dart';
import 'package:crowdfans/components/profile/membership_subscribe_terms_checkbox.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
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

  testWidgets(
    'CF-206 print: copy, handle roxo, pill 2.684 e fixture 240',
    (tester) async {
      final colors = AppColors.light;
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: ListView(
              children: [
                MembershipSubscribeBalancePill(
                  balance: cfTempMockMembershipSummary.jamCoinsBalanceLabel,
                ),
                MembershipSubscribeArtistSummary(
                  artistName: cfTempMockMembershipSummary.artistName,
                  artistHandle: cfTempMockMembershipSummary.artistHandle,
                  pricePerMonth: cfTempMockMembershipSummary.pricePerMonth,
                ),
                const MembershipSubscribeExpectations(),
                AppButton(
                  label: 'Termos de Uso e Condições de Serviço',
                  variant: AppButtonVariant.outline,
                  onPressed: () {},
                ),
                MembershipSubscribeTermsCheckbox(
                  accepted: false,
                  onChanged: (_) {},
                ),
                AppButton(
                  label: 'Assinar',
                  variant: AppButtonVariant.dark,
                  disabled: true,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('2.684'), findsOneWidget);
      expect(find.text('Banda Uelo'), findsOneWidget);
      expect(find.text('@bandauelo'), findsOneWidget);
      expect(find.text('240 Jam Coins / mês'), findsOneWidget);
      expect(find.text('Antes de confirmar sua assinatura...'), findsOneWidget);
      expect(
        find.textContaining(
          'Antes de seguir para o pagamento, queremos alinhar as expectativas',
        ),
        findsOneWidget,
      );
      expect(find.textContaining('Apoio em primeiro lugar:'), findsOneWidget);
      expect(
        find.textContaining(
          'seu principal papel é o de patrono',
        ),
        findsOneWidget,
      );
      expect(find.textContaining('Conteúdo e Interação:'), findsOneWidget);
      expect(
        find.textContaining(
          'não garante uma frequência fixa de postagens exclusivas',
        ),
        findsOneWidget,
      );
      expect(
        find.text('Termos de Uso e Condições de Serviço'),
        findsOneWidget,
      );
      expect(
        find.text(
          'Ao prosseguir, você está de acordo com os Termos de Uso e Condições de Serviço',
        ),
        findsOneWidget,
      );

      final handle = tester.widget<Text>(find.text('@bandauelo'));
      expect(handle.style?.color, colors.primary);

      final price = tester.widget<Text>(find.text('240 Jam Coins / mês'));
      expect(price.style?.color, colors.primary);

      expect(
        tester.widgetList<FilledButton>(find.byType(FilledButton)).last.onPressed,
        isNull,
      );
    },
  );
}
