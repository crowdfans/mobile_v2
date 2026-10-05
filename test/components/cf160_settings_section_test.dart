import 'package:crowdfans/components/profile/profile_settings_section.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

/// CF-160 — cabeçalhos sem faixa preenchida + respiro + separadores de grupo.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrap({
    required Widget child,
    EdgeInsets viewInsets = EdgeInsets.zero,
  }) {
    return MaterialApp(
      theme: buildCrowdFansTheme(Brightness.light),
      home: MediaQuery(
        data: MediaQueryData(size: const Size(390, 844), viewInsets: viewInsets),
        child: Scaffold(
          backgroundColor: AppColors.light.background,
          body: child,
        ),
      ),
    );
  }

  List<ProfileSettingItem> sampleItems({int count = 3}) {
    return List.generate(
      count,
      (i) => ProfileSettingItem(
        id: 'item-$i',
        label: 'Opção $i',
        asset: 'assets/icons/Users/user-01.svg',
        onTap: () {},
      ),
    );
  }

  // --- GREEN: print LEFT — títulos no fundo + faixa entre grupos + linha ---
  testWidgets(
    'CF-160 green: cabeçalho sem preenchimento surfaceAlt; ícone+nome+seta na linha',
    (tester) async {
      await tester.pumpWidget(
        wrap(
          child: ProfileSettingsSection(
            title: 'Como você usa a Crowd Fans',
            items: sampleItems(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final title = find.text('Como você usa a Crowd Fans');
      expect(title, findsOneWidget);

      // Título não pode viver dentro de ColoredBox com surfaceAlt (print RIGHT).
      final titleElement = tester.element(title);
      final titleBox = tester.renderObject(title) as RenderBox;
      final titleTop = titleBox.localToGlobal(Offset.zero).dy;
      var foundFilledHeader = false;
      titleElement.visitAncestorElements((el) {
        final w = el.widget;
        if (w is ColoredBox && w.color == AppColors.light.surfaceAlt) {
          final box = el.renderObject;
          if (box is RenderBox &&
              box.hasSize &&
              box.size.height <= 48 &&
              box.localToGlobal(Offset.zero).dy <= titleTop + 4) {
            foundFilledHeader = true;
            return false;
          }
        }
        return true;
      });
      expect(
        foundFilledHeader,
        isFalse,
        reason: 'Cabeçalho deve ficar sobre o fundo da tela (sem faixa)',
      );

      // Ícone, nome e seta na mesma Row.
      final row = find.ancestor(
        of: find.text('Opção 0'),
        matching: find.byType(Row),
      );
      expect(row, findsWidgets);
      final iconsInRow = find.descendant(
        of: row.first,
        matching: find.byType(SvgPicture),
      );
      expect(iconsInRow, findsNWidgets(2)); // ícone + chevron
      expect(
        find.descendant(of: row.first, matching: find.text('Opção 0')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'CF-160 green: respiro entre opções e faixa discreta entre grupos',
    (tester) async {
      await tester.pumpWidget(
        wrap(
          child: Column(
            children: [
              ProfileSettingsSection(
                title: 'Sua Conta',
                items: sampleItems(count: 2),
              ),
              ProfileSettingsSection(
                title: 'Conteúdos',
                items: [
                  ProfileSettingItem(
                    id: 'blocked',
                    label: 'Usuários Bloqueados',
                    asset: 'assets/icons/General/slash-octagon.svg',
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      final y0 = tester.getTopLeft(find.byKey(const Key('settings-item-item-0'))).dy;
      final y1 = tester.getTopLeft(find.byKey(const Key('settings-item-item-1'))).dy;
      final pitch = y1 - y0;
      // Print LEFT: pitch ~84–92 (app atual compacto ~52–68).
      expect(
        pitch,
        greaterThanOrEqualTo(80),
        reason: 'Respiro entre opções deve aproximar a referência',
      );

      // Faixa de grupo: ColoredBox surfaceAlt com altura discreta (≥10).
      final dividers = tester
          .widgetList<ColoredBox>(find.byType(ColoredBox))
          .where((c) => c.color == AppColors.light.surfaceAlt)
          .toList();
      expect(dividers, isNotEmpty);
      var tallEnough = false;
      for (final d in dividers) {
        final el = find.byWidget(d);
        final size = tester.getSize(el);
        if (size.height >= 10 && size.width > 200) {
          tallEnough = true;
          break;
        }
      }
      expect(
        tallEnough,
        isTrue,
        reason: 'Grupos separados por faixa discreta surfaceAlt',
      );

      expect(find.text('Sua Conta'), findsOneWidget);
      expect(find.text('Conteúdos'), findsOneWidget);
      expect(find.text('Usuários Bloqueados'), findsOneWidget);
    },
  );

  // --- RED: vazio / perigo / sem seta ---
  testWidgets('CF-160 red: seção vazia ainda mostra título e não quebra', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        child: const ProfileSettingsSection(
          title: 'Conteúdos',
          items: [],
          showDivider: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Conteúdos'), findsOneWidget);
    expect(find.byType(InkWell), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('CF-160 red: item danger sem chevron e com cor de perigo', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      wrap(
        child: ProfileSettingsSection(
          title: 'Sessão',
          showDivider: false,
          items: [
            ProfileSettingItem(
              id: 'logout',
              label: 'Sair da conta',
              asset: 'assets/icons/General/log-out-01.svg',
              showChevron: false,
              danger: true,
              onTap: () => tapped = true,
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    final label = tester.widget<Text>(find.text('Sair da conta'));
    expect(label.style?.color, AppColors.light.danger);

    final row = find.ancestor(
      of: find.text('Sair da conta'),
      matching: find.byType(Row),
    );
    // Só o ícone à esquerda — sem chevron.
    expect(
      find.descendant(of: row.first, matching: find.byType(SvgPicture)),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('settings-item-logout')));
    await tester.pump();
    expect(tapped, isTrue);
  });

  // --- EDGE: texto longo + teclado ---
  testWidgets('CF-160 edge: rótulo longo não estoura a Row', (tester) async {
    await tester.pumpWidget(
      wrap(
        child: ProfileSettingsSection(
          title: 'Como você usa a Crowd Fans',
          items: [
            ProfileSettingItem(
              id: 'long',
              label:
                  'Uma opção com texto extremamente longo para validar ellipsis '
                  'e alinhamento ícone nome seta na mesma linha sem overflow',
              asset: 'assets/icons/Users/user-01.svg',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    final item = find.byKey(const Key('settings-item-long'));
    expect(item, findsOneWidget);
    final row = find.descendant(of: item, matching: find.byType(Row));
    expect(row, findsOneWidget);
    expect(
      find.descendant(of: row, matching: find.byType(SvgPicture)),
      findsNWidgets(2),
    );
    final label = tester.widget<Text>(
      find.descendant(of: row, matching: find.byType(Text)).first,
    );
    expect(label.maxLines, 1);
    expect(label.overflow, TextOverflow.ellipsis);
  });

  testWidgets('CF-160 edge: viewInsets (teclado) mantém layout da seção', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        viewInsets: const EdgeInsets.only(bottom: 320),
        child: ProfileSettingsSection(
          title: 'Sua Conta',
          items: sampleItems(count: 1),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sua Conta'), findsOneWidget);
    expect(find.text('Opção 0'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
