import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/profile/wallet_payment_method_tabs.dart';
import 'package:crowdfans/components/profile/wallet_payment_summary_card.dart';
import 'package:crowdfans/components/profile/wallet_pix_receipt.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/screens/profile/profile_wallet_payment_screen.dart';
import 'package:crowdfans/services/wallet_service.dart';
import 'package:crowdfans/utils/wallet_user_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // --- green ---
  testWidgets(
    'CF-170 green: tela Pagamento com moeda dourada, botão escuro e sem sandbox',
    (tester) async {
      final pack = Cf170WalletPackMock.packs().firstWhere(
        (p) => p.id == 'pack_240',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: ProfileWalletPaymentScreen(
            packId: pack.id,
            label: pack.label,
            coins: '${pack.coins}',
            priceCents: pack.priceCents,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Pagamento'), findsOneWidget);
      expect(find.text('240'), findsOneWidget);
      expect(find.text('200 JC + 40 bônus'), findsOneWidget);
      expect(find.text('R\$ 19,90'), findsOneWidget);
      expect(find.text('PIX'), findsOneWidget);
      expect(find.text('Débito'), findsOneWidget);
      expect(find.text('Crédito'), findsOneWidget);
      expect(find.text('Pagamento por Pix'), findsOneWidget);
      expect(
        find.text(
          'Ao tocar em Próximo, o código Pix copia e cola será gerado para esse pacote.',
        ),
        findsOneWidget,
      );
      expect(find.textContaining('sandbox'), findsNothing);
      expect(find.byIcon(Icons.toll), findsNothing);

      final image = tester.widget<Image>(
        find.descendant(
          of: find.byType(WalletPaymentSummaryCard),
          matching: find.byType(Image),
        ),
      );
      expect(
        (image.image as AssetImage).assetName,
        'assets/images/jam-coin.png',
      );

      expect(find.text('Próximo'), findsOneWidget);
      expect(find.byType(AppButton), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(find.byType(FilledButton))
            .style!
            .backgroundColor!
            .resolve({}),
        AppPalette.platinum900,
      );
    },
  );

  testWidgets(
    'CF-170 green: resumo isolado usa jam-coin e AppButton dark',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: Column(
              children: [
                const WalletPaymentSummaryCard(
                  coinsLabel: '240',
                  detail: '200 JC + 40 bônus',
                  priceLabel: 'R\$ 19,90',
                ),
                AppButton(
                  label: 'Próximo',
                  variant: AppButtonVariant.dark,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.toll), findsNothing);
      final image = tester.widget<Image>(find.byType(Image));
      expect(
        (image.image as AssetImage).assetName,
        'assets/images/jam-coin.png',
      );
      expect(
        tester
            .widget<FilledButton>(find.byType(FilledButton))
            .style!
            .backgroundColor!
            .resolve({}),
        AppPalette.platinum900,
      );
    },
  );

  // --- red ---
  testWidgets('CF-170 red: packId vazio bloqueia pagamento', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: const ProfileWalletPaymentScreen(packId: ''),
      ),
    );
    await tester.pump();

    expect(find.text('Pacote não encontrado'), findsOneWidget);
    expect(find.text('Próximo'), findsNothing);
    expect(find.byType(WalletPaymentSummaryCard), findsNothing);
    expect(find.byType(WalletPaymentMethodTabs), findsNothing);
  });

  testWidgets(
    'CF-170 red: recibo pago não exibe a palavra sandbox',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: WalletPixReceipt(
              receipt: const WalletCheckoutResult(
                checkoutId: 'chk-1',
                packId: 'pack_240',
                coins: 240,
                status: 'paid',
                provider: 'pix',
                message: 'Checkout sandbox ok',
              ),
              onCopyPix: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Pago'), findsOneWidget);
      expect(find.textContaining('sandbox'), findsNothing);
      expect(find.textContaining('Checkout sandbox'), findsNothing);
    },
  );

  test('CF-170 red: filtro omite sandbox / RevenueCat / CF-*', () {
    expect(walletUserFacingMessage('Checkout sandbox ok'), isNull);
    expect(walletUserFacingMessage('via RevenueCat'), isNull);
    expect(walletUserFacingMessage('fix CF-54'), isNull);
    expect(walletUserFacingMessage(''), isNull);
    expect(walletUserFacingMessage(null), isNull);
  });

  // --- edge ---
  testWidgets(
    'CF-170 edge: Débito/Crédito mantêm abas e não liberam cartão',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: const ProfileWalletPaymentScreen(
            packId: 'pack_240',
            label: '200 JC + 40 bônus',
            coins: '240',
            priceCents: 1990,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Débito'));
      await tester.pump();

      expect(find.text('PIX'), findsOneWidget);
      expect(find.text('Débito'), findsOneWidget);
      expect(find.text('Crédito'), findsOneWidget);
      expect(find.text('Pagamento por Pix'), findsNothing);
      expect(
        find.textContaining('Por enquanto use PIX'),
        findsOneWidget,
      );
      expect(find.textContaining('sandbox'), findsNothing);
      expect(find.text('Próximo'), findsOneWidget);
    },
  );

  testWidgets(
    'CF-170 edge: label longo e mensagem segura no filtro',
    (tester) async {
      const longLabel =
          '200 JC + 40 bônus — pacote especial de lançamento com texto bem longo para layout';
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: const ProfileWalletPaymentScreen(
            packId: 'pack_240',
            label: longLabel,
            coins: '240',
            priceCents: 1990,
          ),
        ),
      );
      await tester.pump();

      expect(find.textContaining('pacote especial de lançamento'), findsOneWidget);
      expect(find.textContaining('sandbox'), findsNothing);
      expect(
        walletUserFacingMessage('PIX gerado para esse pacote.'),
        'PIX gerado para esse pacote.',
      );
      expect(kUseCf170WalletPackMocks, isFalse);
      expect(
        Cf170WalletPackMock.packs().any((p) => p.coins == 240),
        isTrue,
      );
    },
  );
}
