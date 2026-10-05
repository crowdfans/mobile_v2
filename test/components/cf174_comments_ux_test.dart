import 'package:crowdfans/components/comments/comment_composer.dart';
import 'package:crowdfans/components/comments/comment_post_context_header.dart';
import 'package:crowdfans/components/comments/comment_row.dart';
import 'package:crowdfans/components/comments/comment_sort_chip.dart';
import 'package:crowdfans/components/comments/comment_thread_header.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/comment_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _homeHarness({
  required String? author,
  required String? handle,
  String draft = '',
  bool popularesSelected = true,
  bool ownComment = false,
}) {
  const comment = CommentItem(
    id: 'c1',
    author: 'Fê Andrade',
    handle: 'fan/feandrade',
    avatarUri: '',
    text: 'Quero mais posts de bastidor assim.',
    minutesAgo: 180,
    votes: 229,
    myVote: 0,
    replies: [],
  );
  return MaterialApp(
    theme: buildCrowdFansTheme(Brightness.light),
    home: Scaffold(
      body: Column(
        children: [
          CommentThreadHeader(
            onBack: () {},
            author: author,
            handle: handle,
            avatarUrl: '',
            onMenu: () {},
          ),
          // CF-174 Home: título da seção (sem card de post — CF-195).
          if ((author ?? '').trim().isNotEmpty ||
              (handle ?? '').trim().isNotEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Comentários',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          Row(
            children: [
              CommentSortChip(
                label: 'Populares',
                selected: popularesSelected,
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              CommentSortChip(
                label: 'Novos',
                selected: !popularesSelected,
                onPressed: () {},
              ),
            ],
          ),
          Expanded(
            child: ListView(
              children: [
                CommentRow(
                  comment: comment,
                  isOwn: ownComment,
                  isReply: false,
                  onOpenProfile: () {},
                  onReply: () {},
                  onReport: () {},
                  onEdit: () {},
                  onDelete: () {},
                  onVoteApplied: (_) {},
                ),
              ],
            ),
          ),
          CommentComposer(
            draft: draft,
            replyAuthor: null,
            editing: false,
            selectedGifUrl: null,
            submitting: false,
            onDraftChanged: (_) {},
            onCancelEdit: () {},
            onCancelReply: () {},
            onRemoveGif: () {},
            onPickGif: () {},
            onSubmit: () {},
          ),
        ],
      ),
    ),
  );
}

void main() {
  // —— GREEN (print CF-174) ——
  testWidgets(
    'CF-174 GREEN: autor no header, Comentários, chip escuro, compositor compacto',
    (tester) async {
      await tester.pumpWidget(
        _homeHarness(author: 'Ponzanelli', handle: '@ponzanelli'),
      );
      await tester.pump();

      expect(find.text('Ponzanelli'), findsOneWidget);
      expect(find.text('@ponzanelli'), findsOneWidget);
      expect(find.text('Comentários'), findsOneWidget);
      expect(find.text('Voltar'), findsNothing);
      expect(find.byKey(const Key('comment-thread-menu')), findsOneWidget);
      expect(find.text('Populares'), findsOneWidget);
      expect(find.text('Novos'), findsOneWidget);
      expect(find.byKey(const Key('comment-gif')), findsOneWidget);
      expect(find.byKey(const Key('comment-submit')), findsNothing);
      expect(find.text('Publicar'), findsNothing);
      expect(find.text('GIF'), findsNothing);
      expect(find.text('Adicione um comentário...'), findsOneWidget);
      expect(find.text('Responder'), findsOneWidget);
      expect(find.text('Editar'), findsNothing);
      expect(find.text('Excluir'), findsNothing);

      final material = tester.widget<Material>(
        find.descendant(
          of: find.widgetWithText(CommentSortChip, 'Populares'),
          matching: find.byType(Material),
        ),
      );
      expect(material.color, AppPalette.platinum900);
    },
  );

  testWidgets(
    'CF-174 GREEN fã-clube: contexto do post acima de Comentários',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: Column(
              children: [
                CommentThreadHeader(
                  onBack: () {},
                  author: 'Ponzanelli',
                  handle: '@ponzanelli',
                  avatarUrl: '',
                ),
                const CommentPostContextHeader(
                  text: 'Post de exemplo no fã-clube',
                  minutesAgo: 45,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Ponzanelli'), findsOneWidget);
      expect(find.text('Post de exemplo no fã-clube'), findsOneWidget);
      expect(find.text('Comentários'), findsOneWidget);
      // Sem duplicar autor no bloco de contexto (só no header).
      expect(find.text('Ponzanelli'), findsOneWidget);
    },
  );

  // —— RED ——
  testWidgets(
    'CF-174 RED: Populares não selecionado não usa variante escura',
    (tester) async {
      await tester.pumpWidget(
        _homeHarness(
          author: 'Ponzanelli',
          handle: '@ponzanelli',
          popularesSelected: false,
        ),
      );
      await tester.pump();

      final material = tester.widget<Material>(
        find.descendant(
          of: find.widgetWithText(CommentSortChip, 'Populares'),
          matching: find.byType(Material),
        ),
      );
      expect(material.color, isNot(AppPalette.platinum900));
    },
  );

  testWidgets(
    'CF-174 RED: sem autor/handle — título só no header, sem Publicar',
    (tester) async {
      await tester.pumpWidget(_homeHarness(author: null, handle: null));
      await tester.pump();

      // ThreadHeader fallback = "Comentários"; harness não duplica a seção.
      expect(find.text('Comentários'), findsOneWidget);
      expect(find.text('Publicar'), findsNothing);
      expect(find.byKey(const Key('comment-submit')), findsNothing);
    },
  );

  // —— EDGE ——
  testWidgets(
    'CF-174 EDGE: rascunho longo revela enviar; autor próprio tem Editar/Excluir no menu',
    (tester) async {
      await tester.pumpWidget(
        _homeHarness(
          author: 'Ponzanelli',
          handle: '@ponzanelli',
          draft: 'x' * 280,
          ownComment: true,
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('comment-submit')), findsOneWidget);
      expect(find.byKey(const Key('comment-gif')), findsNothing);

      await tester.tap(
        find.descendant(
          of: find.byType(CommentRow),
          matching: find.byType(PopupMenuButton<String>),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Editar'), findsOneWidget);
      expect(find.text('Excluir'), findsOneWidget);
      expect(find.text('Denunciar'), findsNothing);
    },
  );

  test('CF-174 EDGE: commentsOf serializa contexto do post na query', () {
    final uri = Uri.parse(
      Pages.commentsOf(
        'post-1',
        author: 'Ponzanelli',
        handle: '@ponzanelli',
        text: 'olá',
        minutesAgo: 12,
        votes: 3,
      ),
    );
    expect(uri.path, '/comments/post-1');
    expect(uri.queryParameters['author'], 'Ponzanelli');
    expect(uri.queryParameters['handle'], '@ponzanelli');
    expect(uri.queryParameters['text'], 'olá');
    expect(uri.queryParameters['minutesAgo'], '12');
    expect(uri.queryParameters['votes'], '3');
  });
}
