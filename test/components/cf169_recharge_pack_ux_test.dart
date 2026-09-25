import 'package:crowdfans/components/profile/wallet_recharge_pack_tile.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/wallet_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CF-169: moeda dourada, seleção lilás e Próximo escuro', (
    tester,
  ) async {
    const pack = JamCoinPack(
      id: 'p1',
      label: '240 JC',
      coins: 240,
      priceCents: 1990,
      productId: 'mid',
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
                featured: true,
                onPressed: () {},
              ),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: AppPalette.platinum900,
                    foregroundColor: AppPalette.platinum50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Próximo'),
                ),
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
    expect(find.text('Mais pedido'), findsOneWidget);

    final material = tester.widget<Material>(
      find
          .descendant(
            of: find.byType(WalletRechargePackTile),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(material.color, const Color(0xFFF3EEFF));

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    final style = button.style!;
    expect(style.backgroundColor!.resolve({}), AppPalette.platinum900);
  });
}
