import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/profile/wallet_payment_confirmed_badge.dart';
import 'package:crowdfans/components/profile/wallet_payment_confirmed_info_note.dart';
import 'package:crowdfans/components/profile/wallet_payment_confirmed_purchase_card.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/screens/profile/profile_wallet_payment_confirmed_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
        ),
        contains('coins=500'),
      );
      expect(Pages.profileWallet, '/me/settings/wallet');
      expect(find.byType(AppButton), findsOneWidget);
    },
  );

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
}
