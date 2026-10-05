import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/profile/wallet_payment_confirmed_badge.dart';
import 'package:crowdfans/components/profile/wallet_payment_confirmed_info_note.dart';
import 'package:crowdfans/components/profile/wallet_payment_confirmed_purchase_card.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/screens/profile/profile_wallet_payment_confirmed_screen.dart';
import 'package:crowdfans/utils/jam_coin_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  test('CF-204: parseJamCoinBonusLabel extrai base e bônus do print', () {
    expect(
      parseJamCoinBonusLabel('200 JC + 40 bônus'),
      equals((baseCoins: 200, bonusCoins: 40)),
    );
    expect(
      parseJamCoinBonusLabel('1.000 JC + 300 bônus'),
      equals((baseCoins: 1000, bonusCoins: 300)),
    );
    expect(parseJamCoinBonusLabel('120 JC'), isNull);
    expect(parseJamCoinBonusLabel(null), isNull);
  });

  test('CF-204: mock TEMP do print permanece 240 = 200 + 40', () {
    expect(cfTempMockRechargeConfirmed.coinsTotal, 240);
    expect(cfTempMockRechargeConfirmed.baseCoins, 200);
    expect(cfTempMockRechargeConfirmed.bonusCoins, 40);
  });

  testWidgets(
    'CF-204: confirmação usa total real e Fechar aponta à carteira',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: const ProfileWalletPaymentConfirmedScreen(
            coinsTotal: 500,
            baseCoins: 400,
            bonusCoins: 100,
            checkoutId: 'chk-abc',
            packId: 'plus',
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Pagamento confirmado'), findsOneWidget);
      expect(find.text('Carteira cheia!'), findsOneWidget);
      expect(
        find.text(
          'Suas Jam Coins chegaram e já estão liberadas para usar no app.',
        ),
        findsOneWidget,
      );
      expect(find.text('Recarga concluída'), findsOneWidget);
      expect(find.text('Detalhes da compra'), findsOneWidget);
      expect(find.text('500'), findsOneWidget);
      expect(find.text('400 JC + 100 bônus'), findsOneWidget);
      expect(find.text('240'), findsNothing);
      expect(find.byType(WalletPaymentConfirmedBadge), findsOneWidget);
      expect(find.byType(WalletPaymentConfirmedPurchaseCard), findsOneWidget);
      expect(find.byType(WalletPaymentConfirmedInfoNote), findsOneWidget);
      expect(find.text('Fechar'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(find.byType(FilledButton))
            .style!
            .backgroundColor!
            .resolve({}),
        AppPalette.platinum900,
      );
      expect(
        Pages.profileWalletPaymentConfirmedOf(
          coins: 500,
          checkoutId: 'chk-abc',
          packId: 'plus',
          baseCoins: 400,
          bonusCoins: 100,
        ),
        allOf(
          contains('coins=500'),
          contains('baseCoins=400'),
          contains('bonusCoins=100'),
          contains('checkoutId=chk-abc'),
        ),
      );
      expect(Pages.profileWallet, '/me/settings/wallet');
      expect(find.byType(AppButton), findsOneWidget);
    },
  );

  testWidgets('CF-204: print 240 com breakdown e Fechar → carteira', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: Pages.profileWalletPaymentConfirmedOf(
        coins: cfTempMockRechargeConfirmed.coinsTotal,
        baseCoins: cfTempMockRechargeConfirmed.baseCoins,
        bonusCoins: cfTempMockRechargeConfirmed.bonusCoins,
        checkoutId: 'chk-print',
        packId: 'pack_240',
      ),
      routes: [
        GoRoute(
          path: Pages.profileWalletPaymentConfirmed,
          builder: (context, state) => ProfileWalletPaymentConfirmedScreen(
            coinsTotal:
                int.tryParse(state.uri.queryParameters['coins'] ?? '') ?? 0,
            checkoutId: state.uri.queryParameters['checkoutId'],
            packId: state.uri.queryParameters['packId'],
            baseCoins: int.tryParse(
              state.uri.queryParameters['baseCoins'] ?? '',
            ),
            bonusCoins: int.tryParse(
              state.uri.queryParameters['bonusCoins'] ?? '',
            ),
          ),
        ),
        GoRoute(
          path: Pages.profileWallet,
          builder: (context, state) => const Scaffold(
            body: Text('carteira-atualizada'),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        theme: buildCrowdFansTheme(Brightness.light),
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pagamento confirmado'), findsOneWidget);
    expect(find.text('Carteira cheia!'), findsOneWidget);
    expect(find.text('240'), findsOneWidget);
    expect(find.text('200 JC + 40 bônus'), findsOneWidget);

    await tester.tap(find.text('Fechar'));
    await tester.pumpAndSettle();
    expect(find.text('carteira-atualizada'), findsOneWidget);
  });

  testWidgets('CF-204: sem bônus não inventa breakdown', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: const ProfileWalletPaymentConfirmedScreen(coinsTotal: 100),
      ),
    );
    await tester.pump();

    expect(find.text('100'), findsOneWidget);
    expect(find.textContaining('bônus'), findsNothing);
  });

  testWidgets('CF-204: ilustração Confetti excluída da semântica', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: const ProfileWalletPaymentConfirmedScreen(
          coinsTotal: 240,
          baseCoins: 200,
          bonusCoins: 40,
        ),
      ),
    );
    await tester.pump();

    final images = tester.widgetList<Image>(find.byType(Image)).toList();
    expect(
      images.any(
        (image) =>
            image.image is AssetImage &&
            (image.image as AssetImage).assetName ==
                'assets/images/Confetti.png' &&
            image.excludeFromSemantics,
      ),
      isTrue,
    );
  });
}
