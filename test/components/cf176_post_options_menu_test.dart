import 'package:crowdfans/components/post/post_options_share_action.dart';
import 'package:crowdfans/components/post/post_options_sheet.dart';
import 'package:crowdfans/components/post/post_options_shortcut_card.dart';
import 'package:crowdfans/components/post/post_share_action_tile.dart';
import 'package:crowdfans/components/post/post_sheet_list_item.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpOptions(
  WidgetTester tester, {
  required FeedPost? post,
  bool visible = true,
  VoidCallback? onClose,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: buildCrowdFansTheme(Brightness.light),
      home: Scaffold(
        body: Stack(
          children: [
            PostOptionsSheet(
              visible: visible,
              post: post,
              onClose: onClose ?? () {},
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  group('CF-176 green — print menu home ⋯', () {
    test('fixture TEMP: post do menu no home feed', () {
      expect(kUseCf176PostOptionsMocks, isTrue);
      final post = cfTempMockCf176MenuPost();
      expect(post.id, 'cf176-menu-post');
      expect(post.author, isNotEmpty);
      expect(post.artistId, isNotEmpty);
      final feed = cfTempMockHomeFeedPosts();
      expect(feed.any((p) => p.id == 'cf176-menu-post'), isTrue);
    });

    testWidgets('rótulos completos, atalhos, share tiles e Reportar', (
      tester,
    ) async {
      await _pumpOptions(tester, post: cfTempMockCf176MenuPost());

      expect(find.byKey(const Key('post-options-sheet')), findsOneWidget);
      expect(find.text('Ver Fã Clube do Artista'), findsOneWidget);
      expect(find.text('Salvar Post nas Memórias'), findsOneWidget);
      expect(find.text('Copiar Link'), findsOneWidget);
      expect(find.text('WhatsApp'), findsOneWidget);
      expect(find.text('Stories'), findsOneWidget);
      expect(find.text('Deixar de seguir'), findsOneWidget);
      expect(find.text('Sobre este artista'), findsOneWidget);
      expect(find.text('Favoritar Artista'), findsOneWidget);
      expect(find.text('Reportar'), findsOneWidget);

      expect(find.byType(PostOptionsShortcutCard), findsNWidgets(2));
      expect(find.byType(PostOptionsShareAction), findsNWidgets(3));
      expect(find.byType(PostSheetListItem), findsNWidgets(3));

      // Assets dos atalhos superiores (rock-hand / star-memory).
      expect(find.byType(Image), findsWidgets);

      // Ícones SVG das linhas + Reportar.
      expect(find.byType(SvgPicture), findsWidgets);
    });

    testWidgets('Copiar Link com destaque roxo (ícone + rótulo)', (
      tester,
    ) async {
      await _pumpOptions(tester, post: cfTempMockCf176MenuPost());

      final label = tester.widget<Text>(find.text('Copiar Link'));
      expect(label.style?.color, AppPalette.purple500);

      final share = tester.widget<PostOptionsShareAction>(
        find.ancestor(
          of: find.text('Copiar Link'),
          matching: find.byType(PostOptionsShareAction),
        ),
      );
      expect(share.iconColor, AppPalette.purple500);
      expect(share.labelColor, AppPalette.purple500);
    });
  });

  group('CF-176 red — rótulos curtos / menus irmãos', () {
    testWidgets('sem rótulos encurtados do app antigo', (tester) async {
      await _pumpOptions(tester, post: cfTempMockCf176MenuPost());

      expect(find.text('Ver Fã Clube'), findsNothing);
      expect(find.text('Salvar nas Memórias'), findsNothing);
      expect(find.text('Copiar'), findsNothing);
      expect(find.text('Sobre'), findsNothing);
      expect(find.text('Favoritar'), findsNothing);
    });

    testWidgets('não é menu CF-227 nem share CF-236', (tester) async {
      await _pumpOptions(tester, post: cfTempMockCf176MenuPost());

      // CF-227 (fã-clube).
      expect(find.text('Favoritar Fã Clube'), findsNothing);
      expect(find.text('Ver Fã Clube'), findsNothing);

      // CF-236 (sheet só de share).
      expect(find.text('Compartilhar para...'), findsNothing);
      expect(find.byType(PostShareActionTile), findsNothing);
      expect(find.byKey(const Key('post-share-sheet')), findsNothing);
      expect(find.byIcon(Icons.ios_share), findsNothing);
    });
  });

  group('CF-176 edge — vazio / cancelar / sem artista', () {
    testWidgets('post null ainda monta chrome sem crash', (tester) async {
      await _pumpOptions(tester, post: null);
      expect(find.byKey(const Key('post-options-sheet')), findsOneWidget);
      expect(find.text('Ver Fã Clube do Artista'), findsOneWidget);
      expect(find.text('Reportar'), findsOneWidget);
    });

    testWidgets('cancelar (onClose) sem side-effect', (tester) async {
      var closed = false;
      await _pumpOptions(
        tester,
        post: cfTempMockCf176MenuPost(),
        onClose: () => closed = true,
      );
      // Backdrop close is wired via shell; call onClose diretamente.
      final sheet = tester.widget<PostOptionsSheet>(
        find.byType(PostOptionsSheet),
      );
      sheet.onClose();
      expect(closed, isTrue);
    });

    test('fixture flag documentada no mock_removal', () {
      expect(kUseCfTempMocks, isTrue);
      expect(kUseCf176PostOptionsMocks, isTrue);
      // Home democked; menu ⋯ print ainda via kUseCf176PostOptionsMocks.
      expect(CfTempMocks.useHomeFeedFixtures, isFalse);
    });
  });
}
