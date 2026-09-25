import 'package:crowdfans/components/post/post_options_share_action.dart';
import 'package:crowdfans/components/post/post_options_shortcut_card.dart';
import 'package:crowdfans/components/post/post_sheet_list_item.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CF-176: rótulos, tiles de share e ícones de lista', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: Column(
            children: [
              Row(
                children: [
                  PostOptionsShortcutCard(
                    label: 'Ver Fã Clube do Artista',
                    asset: 'assets/images/rock-hand.png',
                    labelColor: AppPalette.purple700,
                    onPressed: () {},
                  ),
                  PostOptionsShortcutCard(
                    label: 'Salvar Post nas Memórias',
                    asset: 'assets/images/star-memory.png',
                    labelColor: AppPalette.yellow600,
                    onPressed: () {},
                  ),
                ],
              ),
              Row(
                children: [
                  PostOptionsShareAction(
                    label: 'Copiar Link',
                    icon: Icons.link,
                    onPressed: () {},
                  ),
                  PostOptionsShareAction(
                    label: 'WhatsApp',
                    asset: 'assets/images/whatsApp.svg',
                    onPressed: () {},
                  ),
                  PostOptionsShareAction(
                    label: 'Stories',
                    asset: 'assets/images/instagram.svg',
                    onPressed: () {},
                  ),
                ],
              ),
              PostSheetListItem(
                label: 'Sobre este artista',
                iconAsset: 'assets/icons/General/eye.svg',
                onPressed: () {},
              ),
              PostSheetListItem(
                label: 'Favoritar Artista',
                iconAsset: 'assets/icons/Shapes/star-01.svg',
                onPressed: () {},
              ),
              const Text('Reportar'),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Ver Fã Clube do Artista'), findsOneWidget);
    expect(find.text('Salvar Post nas Memórias'), findsOneWidget);
    expect(find.text('Copiar Link'), findsOneWidget);
    expect(find.text('Sobre este artista'), findsOneWidget);
    expect(find.text('Favoritar Artista'), findsOneWidget);
    expect(find.text('Reportar'), findsOneWidget);
    expect(find.text('Ver Fã Clube'), findsNothing);
    expect(find.text('Salvar nas Memórias'), findsNothing);
    expect(find.byType(Material), findsWidgets);
  });
}
