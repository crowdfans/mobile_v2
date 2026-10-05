import 'package:crowdfans/components/profile/profile_state.dart';
import 'package:crowdfans/components/profile/wallet_recharge_pack_tile.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/screens/profile/profile_wallet_recharge_screen.dart';
import 'package:crowdfans/services/wallet_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CF-169 green', () {
    testWidgets('moeda dourada, seleção lilás, Mais pedido e Próximo escuro', (
      tester,
    ) async {
      const pack = JamCoinPack(
        id: 'p1',
        label: '200 JC + 40 bônus',
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
                      shape: const StadiumBorder(),
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
      expect(
        (image.image as AssetImage).assetName,
        'assets/images/jam-coin.png',
      );
      expect(find.byIcon(Icons.toll), findsNothing);
      expect(find.text('Mais pedido'), findsOneWidget);
      expect(find.text('240'), findsOneWidget);
      expect(find.text('200 JC + 40 bônus'), findsOneWidget);
      expect(find.text('R\$ 19,90'), findsOneWidget);

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
      expect(style.shape!.resolve({}), isA<StadiumBorder>());
    });

    test('catálogo TEMP do print (não Starter/Plus/Pro da API)', () {
      final packs = Cf170WalletPackMock.packs();
      expect(packs.map((p) => p.coins).toList(), [120, 240, 600, 1300, 2100, 2800]);
      expect(packs.map((p) => p.priceCents).toList(), [
        990,
        1990,
        4990,
        9990,
        14990,
        19999,
      ]);
      expect(packs[1].label, '200 JC + 40 bônus');
      expect(packs.any((p) => p.label.contains('Starter')), isFalse);
      expect(packs.any((p) => p.label.contains('Plus')), isFalse);
      expect(packs.any((p) => p.label.contains('Pro')), isFalse);
    });

    test('resolve ignora catálogo legado da API quando mock TEMP ligado', () {
      const apiLegacy = [
        JamCoinPack(
          id: 'starter',
          coins: 100,
          priceCents: 990,
          label: 'Starter 100',
        ),
      ];
      final resolved = resolveWalletRechargePacks(apiLegacy);
      expect(resolved.map((p) => p.coins).toList(), [
        120,
        240,
        600,
        1300,
        2100,
        2800,
      ]);
      expect(resolved.any((p) => p.id == 'starter'), isFalse);
    });
  });

  group('CF-169 red', () {
    testWidgets('sem ícone roxo toll e sem badge fora do 240', (tester) async {
      const pack = JamCoinPack(
        id: 'p2',
        label: '120 JC',
        coins: 120,
        priceCents: 990,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: WalletRechargePackTile(
              pack: pack,
              selected: false,
              featured: false,
              onPressed: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.toll), findsNothing);
      expect(find.text('Mais pedido'), findsNothing);
      expect(find.byIcon(Icons.radio_button_off), findsOneWidget);

      final material = tester.widget<Material>(
        find
            .descendant(
              of: find.byType(WalletRechargePackTile),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(material.color, isNot(const Color(0xFFF3EEFF)));
    });

    testWidgets('lista vazia: sem Próximo e estado de erro', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: ProfileState(
              title: 'Pacotes indisponíveis',
              message: 'Não foi possível carregar os pacotes.',
              actionLabel: 'Tentar novamente',
              onAction: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Próximo'), findsNothing);
      expect(find.text('Pacotes indisponíveis'), findsOneWidget);
      expect(find.text('Tentar novamente'), findsOneWidget);
      expect(
        resolveWalletRechargePacks(const [], useTempMocks: false),
        isEmpty,
      );
    });
  });

  group('CF-169 edge', () {
    testWidgets('formata 1.300 e preço BR; label longa não estoura', (
      tester,
    ) async {
      const pack = JamCoinPack(
        id: 'p3',
        label: '1.000 JC + 300 bônus — pacote promocional estendido',
        coins: 1300,
        priceCents: 9990,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: SizedBox(
              width: 360,
              child: WalletRechargePackTile(
                pack: pack,
                selected: false,
                featured: false,
                onPressed: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('1.300'), findsOneWidget);
      expect(find.text('R\$ 99,90'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tela recarga: mock TEMP renderiza print e Próximo escuro', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: const ProfileWalletRechargeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Recarregar Jam Coins'), findsOneWidget);
      expect(find.text('Escolha a quantidade'), findsOneWidget);
      expect(find.text('Starter 100'), findsNothing);
      expect(find.text('Plus 500'), findsNothing);
      expect(find.text('Mais pedido'), findsOneWidget);
      expect(find.text('R\$ 49,90'), findsOneWidget);
      expect(find.text('2.100'), findsOneWidget);

      // Último pacote do print fica abaixo da dobra — scroll no ListView.
      await tester.scrollUntilVisible(
        find.text('2.800'),
        80,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('2.800'), findsOneWidget);
      expect(find.text('R\$ 199,99'), findsOneWidget);

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(
        button.style!.backgroundColor!.resolve({}),
        AppPalette.platinum900,
      );
      expect(button.style!.shape!.resolve({}), isA<StadiumBorder>());
    });

    test('fixtures off devolve catálogo da API sem sobrescrever', () {
      const apiLegacy = [
        JamCoinPack(
          id: 'starter',
          coins: 100,
          priceCents: 990,
          label: 'Starter 100',
        ),
      ];
      final resolved = resolveWalletRechargePacks(
        apiLegacy,
        useTempMocks: false,
      );
      expect(resolved.single.id, 'starter');
    });
  });
}
