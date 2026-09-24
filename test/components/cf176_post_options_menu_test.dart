import 'package:crowdfans/components/post/post_options_share_action.dart';
import 'package:crowdfans/components/post/post_options_shortcut_card.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CF-176: rótulos e assets do menu do post', (tester) async {
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
                    onPressed: () {},
                  ),
                  PostOptionsShortcutCard(
                    label: 'Salvar Post nas Memórias',
                    asset: 'assets/images/star-memory.png',
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
              const Text('Sobre este artista'),
              const Text('Favoritar Artista'),
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
    expect(find.text('Ver Fã Clube'), findsNothing);
    expect(find.text('Salvar nas Memórias'), findsNothing);
  });
}
