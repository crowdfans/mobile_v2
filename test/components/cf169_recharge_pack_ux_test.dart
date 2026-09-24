import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/profile/wallet_recharge_pack_tile.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/wallet_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CF-169: moeda dourada e botão Próximo escuro', (tester) async {
    const pack = JamCoinPack(
      id: 'p1',
      label: 'Starter',
      coins: 100,
      priceCents: 999,
      productId: 'starter',
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: Column(
            children: [
              WalletRechargePackTile(
                pack: pack,
                selected: true,
                onPressed: () {},
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

    expect(find.byType(Image), findsOneWidget);
    final image = tester.widget<Image>(find.byType(Image));
    expect((image.image as AssetImage).assetName, 'assets/images/jam-coin.png');
    expect(find.byIcon(Icons.toll), findsNothing);

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    final style = button.style!;
    expect(
      style.backgroundColor!.resolve({}),
      AppPalette.platinum900,
    );
  });
}
