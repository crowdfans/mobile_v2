import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/profile/wallet_payment_summary_card.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CF-170: resumo com moeda dourada, botão escuro, sem sandbox', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: Column(
            children: [
              const WalletPaymentSummaryCard(
                coinsLabel: '100',
                detail: 'Starter',
                priceLabel: 'R\$ 9,99',
              ),
              const Text(
                'Ao tocar em Próximo, o código Pix copia e cola será gerado para esse pacote.',
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
    expect((image.image as AssetImage).assetName, 'assets/images/jam-coin.png');
    expect(find.textContaining('sandbox'), findsNothing);
    expect(
      tester
          .widget<FilledButton>(find.byType(FilledButton))
          .style!
          .backgroundColor!
          .resolve({}),
      AppPalette.platinum900,
    );
  });
}
