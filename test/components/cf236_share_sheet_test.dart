import 'package:crowdfans/components/post/post_options_sheet.dart';
import 'package:crowdfans/components/post/post_share_action_tile.dart';
import 'package:crowdfans/components/post/post_share_sheet.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:crowdfans/services/post_share_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CF-236 fixture: Mayra texto 84/11/3 no home feed', () {
    final post = cfTempMockCf236SharePost();
    expect(post.id, 'cf236-mayra-share');
    expect(post.author, 'Mayra');
    expect(post.handle, '@mayra');
    expect(post.rank, '#3');
    expect(post.votes, 84);
    expect(post.comments, 11);
    expect(post.shares, 3);
    expect(post.type, PostType.text);
    expect(post.isExclusive, isFalse);

    final feed = cfTempMockHomeFeedPosts();
    expect(feed.any((p) => p.id == 'cf236-mayra-share'), isTrue);
  });

  test('CF-236: abrir destino não muda contagem local do post', () {
    final post = cfTempMockCf236SharePost();
    expect(post.shares, 3);
    final message = PostShareService.buildPostShareMessage(post);
    expect(message, contains(PostShareService.postLink(post)));
    expect(post.shares, 3);
  });

  testWidgets('CF-236: share sheet sem título; tiles e Compartilhar para', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: Stack(
            children: [
              PostShareSheet(
                visible: true,
                post: cfTempMockCf236SharePost(),
                onClose: () {},
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const Key('post-share-sheet')), findsOneWidget);
    expect(find.text('Copiar Link'), findsOneWidget);
    expect(find.text('WhatsApp'), findsOneWidget);
    expect(find.text('Stories'), findsOneWidget);
    expect(find.text('Compartilhar para...'), findsOneWidget);
    // Print CF-236: sem título “Compartilhar” (só alça + tiles).
    expect(find.text('Compartilhar'), findsNothing);
    expect(find.byIcon(Icons.ios_share), findsOneWidget);
    expect(find.byType(PostShareActionTile), findsNWidgets(3));
    // Distinto do menu de gerenciamento do post.
    expect(find.text('Denunciar'), findsNothing);
    expect(find.text('Reportar'), findsNothing);
    expect(find.text('Excluir'), findsNothing);
    expect(find.text('Editar'), findsNothing);
    expect(find.text('Ver Fã Clube do Artista'), findsNothing);
    expect(find.text('Salvar Post nas Memórias'), findsNothing);
    expect(find.text('Deixar de seguir'), findsNothing);
    expect(find.text('Favoritar Artista'), findsNothing);
  });

  testWidgets('CF-236: menu ⋯ tem gestão; sem Compartilhar para…', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: Stack(
            children: [
              PostOptionsSheet(
                visible: true,
                post: cfTempMockCf236SharePost(),
                onClose: () {},
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const Key('post-options-sheet')), findsOneWidget);
    expect(find.text('Ver Fã Clube do Artista'), findsOneWidget);
    expect(find.text('Salvar Post nas Memórias'), findsOneWidget);
    expect(find.text('Reportar'), findsOneWidget);
    expect(find.text('Deixar de seguir'), findsOneWidget);
    // Share sheet-only chrome must not appear on manage menu.
    expect(find.text('Compartilhar para...'), findsNothing);
    expect(find.byType(PostShareActionTile), findsNothing);
    expect(find.byKey(const Key('post-share-sheet')), findsNothing);
  });

  testWidgets('CF-236: cancelar (onClose) volta ao post sem side-effect', (
    tester,
  ) async {
    var closed = false;
    final post = cfTempMockCf236SharePost();
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: PostShareSheet(
            visible: true,
            post: post,
            onClose: () => closed = true,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Simula dismiss do sheet (backdrop / alça) — só onClose.
    final state = tester.element(find.byType(PostShareSheet));
    final sheet = state.widget as PostShareSheet;
    sheet.onClose();
    expect(closed, isTrue);
    expect(post.shares, 3);
  });
}
