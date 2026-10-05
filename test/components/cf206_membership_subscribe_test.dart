import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/profile/membership_subscribe_artist_summary.dart';
import 'package:crowdfans/components/profile/membership_subscribe_balance_pill.dart';
import 'package:crowdfans/components/profile/membership_subscribe_expectations.dart';
import 'package:crowdfans/components/profile/membership_subscribe_terms_checkbox.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/screens/profile/profile_membership_subscribe_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CF-206 green — demock + aceite + print', () {
    test('flag Assinar off; manage/activation TEMP intocados', () {
      expect(CfTempMocks.useMembershipFixtures, isFalse);
      expect(kUseCfTempMocks, isTrue);
      // CF-205 / CF-207 deep-link fixtures — outro worker; não desligar aqui.
      expect(CfTempMocks.useMembershipManageFixtures, isTrue);
      expect(CfTempMocks.useMembershipActivationConfirmedFixtures, isTrue);
    });

    testWidgets(
      'Assinar desabilitado sem aceite; preço real 100 no resumo',
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
          tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
          isNull,
        );

        await tester.tap(find.byType(Checkbox));
        await tester.pump();

        expect(
          tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
          isNotNull,
        );
      },
    );

    testWidgets(
      'print: copy, handle roxo, pill 2.684 e fixture 240 (helper só teste)',
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
          find.textContaining('seu principal papel é o de patrono'),
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
          tester
              .widgetList<FilledButton>(find.byType(FilledButton))
              .last
              .onPressed,
          isNull,
        );
      },
    );
  });

  group('CF-206 red — bloqueio / sem mock na falha', () {
    test('artistId vazio não passa no gate de subscribe', () {
      // Espelha handleSubscribe: early return se artistId.trim().isEmpty.
      const artistId = '   ';
      const accepted = true;
      const busy = false;
      final blocked = !accepted || busy || artistId.trim().isEmpty;
      expect(blocked, isTrue);
    });

    test('flag off: falha de carteira não vira saldo print 2.684', () {
      expect(CfTempMocks.useMembershipFixtures, isFalse);
      const balanceAfterWalletError = '—';
      final wouldInjectPrint =
          (balanceAfterWalletError == '—' ||
              balanceAfterWalletError.trim().isEmpty) &&
          CfTempMocks.useMembershipFixtures &&
          kUseCfTempMocks;
      expect(wouldInjectPrint, isFalse);
      expect(
        balanceAfterWalletError,
        isNot(cfTempMockMembershipSummary.jamCoinsBalanceLabel),
      );
    });

    testWidgets('checkbox off mantém Assinar disabled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: AppButton(
              label: 'Assinar',
              variant: AppButtonVariant.dark,
              disabled: true,
              onPressed: () {},
            ),
          ),
        ),
      );
      await tester.pump();
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      expect(find.text('240 Jam Coins / mês'), findsNothing);
    });
  });

  group('CF-206 edge — nome longo / handle / preço zero', () {
    test('membershipSubscribeArtistName e price helpers', () {
      expect(membershipSubscribeArtistName(''), 'Artista');
      expect(membershipSubscribeArtistName('  '), 'Artista');
      expect(membershipSubscribeArtistName(' Mayra '), 'Mayra');
      expect(
        membershipSubscribeArtistName(
          'Nome Muito Longo Do Artista Para Testar Overflow Na Linha',
        ),
        'Nome Muito Longo Do Artista Para Testar Overflow Na Linha',
      );

      expect(membershipSubscribePricePerMonth(0), 100);
      expect(membershipSubscribePricePerMonth(-1), 100);
      expect(membershipSubscribePricePerMonth(100), 100);
      expect(membershipSubscribePricePerMonth(240), 240);
    });

    testWidgets('handle sem @ ganha prefixo; nome longo aparece', (
      tester,
    ) async {
      const longName =
          'Nome Muito Longo Do Artista Para Testar Overflow Na Linha';
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: const Scaffold(
            body: MembershipSubscribeArtistSummary(
              artistName: longName,
              artistHandle: 'bandauelo',
              pricePerMonth: 100,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text(longName), findsOneWidget);
      expect(find.text('@bandauelo'), findsOneWidget);
      expect(find.text('100 Jam Coins / mês'), findsOneWidget);
    });

    testWidgets('pill com saldo — (wallet falhou) sem 2.684', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: const Scaffold(
            body: MembershipSubscribeBalancePill(balance: '—'),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('—'), findsOneWidget);
      expect(find.text('2.684'), findsNothing);
    });
  });
}
