import 'package:crowdfans/components/comments/comment_composer.dart';
import 'package:crowdfans/components/comments/comment_reply_banner.dart';
import 'package:crowdfans/components/comments/comment_row.dart';
import 'package:crowdfans/components/comments/comment_sort_chip.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/comment_service.dart';
import 'package:crowdfans/utils/comment_thread_rules.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

CommentItem _root({
  String id = 'c1',
  int votes = 10,
  int minutesAgo = 60,
  List<CommentItem> replies = const [],
}) {
  return CommentItem(
    id: id,
    author: 'Fê Andrade',
    handle: 'fan/feandrade',
    avatarUri: '',
    text: 'Quero mais posts de bastidor assim.',
    minutesAgo: minutesAgo,
    votes: votes,
    myVote: 0,
    replies: replies,
  );
}

CommentItem _reply({
  String id = 'r1',
  String parentId = 'c1',
  int votes = 2,
  int minutesAgo = 30,
}) {
  return CommentItem(
    id: id,
    author: 'Rafa Nogueira',
    handle: 'fan/rafanogueira',
    avatarUri: '',
    text: 'Esse tipo de conteúdo sempre rende.',
    minutesAgo: minutesAgo,
    votes: votes,
    myVote: 0,
    parentCommentId: parentId,
    replies: const [],
  );
}

Widget _wrap(
  Widget child, {
  double keyboardInset = 0,
  double textScale = 1,
}) {
  return MaterialApp(
    theme: buildCrowdFansTheme(Brightness.light),
    builder: (context, childWidget) {
      final base = MediaQuery.of(context);
      return MediaQuery(
        data: base.copyWith(
          viewInsets: EdgeInsets.only(bottom: keyboardInset),
          textScaler: TextScaler.linear(textScale),
        ),
        child: childWidget!,
      );
    },
    home: Scaffold(
      resizeToAvoidBottomInset: false,
      body: child,
    ),
  );
}

void main() {
  group('CF-69 green', () {
    test('Populares ordena por votos↓; Novos por mais recente', () {
      final a = _root(id: 'a', votes: 5, minutesAgo: 10);
      final b = _root(id: 'b', votes: 20, minutesAgo: 100);
      final c = _root(id: 'c', votes: 5, minutesAgo: 2);

      final popular = CommentThreadRules.sorted(
        [a, b, c],
        popular: true,
      );
      expect(popular.map((e) => e.id).toList(), ['b', 'c', 'a']);

      final novos = CommentThreadRules.sorted(
        [a, b, c],
        popular: false,
      );
      expect(novos.map((e) => e.id).toList(), ['c', 'a', 'b']);
    });

    test('Responder em nested usa raiz como parentCommentId (Instagram)', () {
      final nested = _reply();
      final root = _root(replies: [nested]);
      final parent = CommentThreadRules.replyParent(
        root: root,
        tapped: nested,
      );
      expect(parent.id, root.id);
      expect(parent.id, isNot(nested.id));
    });

    testWidgets(
      'chips Populares|Novos, compositor sticky+GIF idle, Responder em reply',
      (tester) async {
        final nested = _reply();
        final root = _root(replies: [nested]);
        var cancelled = false;

        await tester.pumpWidget(
          _wrap(
            Column(
              children: [
                Row(
                  children: [
                    CommentSortChip(
                      label: 'Populares',
                      selected: true,
                      onPressed: () {},
                    ),
                    CommentSortChip(
                      label: 'Novos',
                      selected: false,
                      onPressed: () {},
                    ),
                  ],
                ),
                Expanded(
                  child: ListView(
                    children: [
                      CommentRow(
                        comment: root,
                        isOwn: false,
                        isReply: false,
                        onOpenProfile: () {},
                        onReply: () {},
                        onReport: () {},
                        onEdit: () {},
                        onDelete: () {},
                        onVoteApplied: (_) {},
                      ),
                      CommentRow(
                        comment: nested,
                        isOwn: false,
                        isReply: true,
                        replyToHandle: root.handle,
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
                  draft: '',
                  replyAuthor: null,
                  editing: false,
                  selectedGifUrl: null,
                  submitting: false,
                  onDraftChanged: (_) {},
                  onCancelEdit: () {},
                  onCancelReply: () => cancelled = true,
                  onRemoveGif: () {},
                  onPickGif: () {},
                  onSubmit: () {},
                ),
              ],
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Populares'), findsOneWidget);
        expect(find.text('Novos'), findsOneWidget);
        // Idle (p11/p12): smile abre GIF; sem ↑ até haver rascunho.
        expect(find.byKey(const Key('comment-gif')), findsOneWidget);
        expect(find.byKey(const Key('comment-submit')), findsNothing);
        expect(find.text('Responder'), findsNWidgets(2));
        expect(cancelled, isFalse);
      },
    );

    testWidgets(
      'modo resposta: banner + mention + só ↑ (sem chip GIF)',
      (tester) async {
        final draft = CommentThreadRules.mentionDraft('fan/rafanogueira');
        await tester.pumpWidget(
          _wrap(
            CommentComposer(
              draft: draft,
              replyAuthor: 'Rafa Nogueira',
              replyHandle: 'fan/rafanogueira',
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
            keyboardInset: 280,
          ),
        );
        await tester.pump();

        expect(find.byType(CommentReplyBanner), findsOneWidget);
        expect(find.textContaining('Respondendo a Rafa Nogueira'), findsOneWidget);
        expect(find.textContaining('fan/rafanogueira'), findsWidgets);
        expect(find.byKey(const Key('comment-submit')), findsOneWidget);
        expect(find.byKey(const Key('comment-gif')), findsNothing);
        expect(find.byKey(const Key('comment-gif-chip')), findsNothing);
      },
    );
  });

  group('CF-69 red', () {
    test('canSubmit nega vazio sem GIF', () {
      expect(CommentThreadRules.canSubmit(draft: '', gifUrl: null), isFalse);
      expect(CommentThreadRules.canSubmit(draft: '   ', gifUrl: ''), isFalse);
      expect(CommentThreadRules.canSubmit(draft: '', gifUrl: '   '), isFalse);
    });

    test('mentionDraft vazio quando handle ausente', () {
      expect(CommentThreadRules.mentionDraft(null), '');
      expect(CommentThreadRules.mentionDraft('  '), '');
    });

    testWidgets('compositor sem submit quando draft vazio em resposta', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          CommentComposer(
            draft: '',
            replyAuthor: 'Rafa Nogueira',
            replyHandle: 'fan/rafanogueira',
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
        ),
      );
      await tester.pump();

      // ↑ aparece no modo resposta, mas disabled (sem onTap útil).
      final submit = find.byKey(const Key('comment-submit'));
      expect(submit, findsOneWidget);
      final ink = tester.widget<InkWell>(submit);
      expect(ink.onTap, isNull);
    });
  });

  group('CF-69 edge', () {
    test('canSubmit aceita só GIF ou só texto', () {
      expect(
        CommentThreadRules.canSubmit(draft: '', gifUrl: 'https://giphy.test/x'),
        isTrue,
      );
      expect(CommentThreadRules.canSubmit(draft: 'oi', gifUrl: null), isTrue);
    });

    test('mentionDraft normaliza handle sem prefixo', () {
      expect(CommentThreadRules.mentionDraft('rafanogueira'), 'fan/rafanogueira ');
      expect(CommentThreadRules.mentionDraft('@rafanogueira'), '@rafanogueira ');
      expect(
        CommentThreadRules.mentionDraft('fan/rafanogueira'),
        'fan/rafanogueira ',
      );
    });

    test('Populares com votos iguais usa minutesAgo (mais novo primeiro)', () {
      final older = _root(id: 'old', votes: 10, minutesAgo: 90);
      final newer = _root(id: 'new', votes: 10, minutesAgo: 5);
      final sorted = CommentThreadRules.sorted(
        [older, newer],
        popular: true,
      );
      expect(sorted.first.id, 'new');
    });

    testWidgets('textScaler alto + teclado mantém banner e ↑', (tester) async {
      await tester.pumpWidget(
        _wrap(
          CommentComposer(
            draft: 'fan/rafanogueira ',
            replyAuthor: 'Rafa Nogueira com nome bem longo para estresse',
            replyHandle: 'fan/rafanogueira',
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
          keyboardInset: 280,
          textScale: 1.6,
        ),
      );
      await tester.pump();

      expect(find.byType(CommentReplyBanner), findsOneWidget);
      expect(find.byKey(const Key('comment-submit')), findsOneWidget);
      final padding = tester.widget<AnimatedPadding>(
        find.byType(AnimatedPadding),
      );
      expect((padding.padding as EdgeInsets).bottom, 280);
    });

    testWidgets('cancelar resposta (✕) dispara onCancelReply', (tester) async {
      var cancelled = false;
      await tester.pumpWidget(
        _wrap(
          CommentComposer(
            draft: 'fan/rafanogueira ',
            replyAuthor: 'Rafa Nogueira',
            replyHandle: 'fan/rafanogueira',
            editing: false,
            selectedGifUrl: null,
            submitting: false,
            onDraftChanged: (_) {},
            onCancelEdit: () {},
            onCancelReply: () => cancelled = true,
            onRemoveGif: () {},
            onPickGif: () {},
            onSubmit: () {},
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.byTooltip('Cancelar resposta'));
      await tester.pump();
      expect(cancelled, isTrue);
    });
  });
}
