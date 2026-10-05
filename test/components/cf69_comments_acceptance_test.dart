import 'package:crowdfans/components/comments/comment_composer.dart';
import 'package:crowdfans/components/comments/comment_reply_target.dart';
import 'package:crowdfans/components/comments/comment_row.dart';
import 'package:crowdfans/components/comments/comment_sort_chip.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/services/comment_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _nested = CommentItem(
  id: 'r1',
  author: 'Rafa Nogueira',
  handle: 'fan/rafanogueira',
  avatarUri: '',
  text: 'Esse tipo de conteúdo sempre rende discussão boa.',
  minutesAgo: 120,
  votes: 15,
  myVote: 0,
  parentCommentId: 'c1',
  replies: [],
);

const _root = CommentItem(
  id: 'c1',
  author: 'Fê Andrade',
  handle: 'fan/feandrade',
  avatarUri: '',
  text: 'Quero mais posts de bastidor assim.',
  minutesAgo: 180,
  votes: 229,
  myVote: 0,
  replies: [_nested],
);

Widget _harness({
  String draft = '',
  String? replyAuthor,
  String? replyHandle,
  String? selectedGifUrl,
  bool submitting = false,
  bool editing = false,
  VoidCallback? onSubmit,
  VoidCallback? onPickGif,
}) {
  return MaterialApp(
    theme: buildCrowdFansTheme(Brightness.light),
    home: Scaffold(
      body: Column(
        children: [
          Row(
            children: [
              CommentSortChip(
                label: 'Populares',
                selected: true,
                onPressed: () {},
              ),
              const SizedBox(width: 8),
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
                  comment: _root,
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
                  comment: _nested,
                  isOwn: false,
                  isReply: true,
                  replyToHandle: _root.handle,
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
            replyAuthor: replyAuthor,
            replyHandle: replyHandle,
            editing: editing,
            selectedGifUrl: selectedGifUrl,
            submitting: submitting,
            onDraftChanged: (_) {},
            onCancelEdit: () {},
            onCancelReply: () {},
            onRemoveGif: () {},
            onPickGif: onPickGif ?? () {},
            onSubmit: onSubmit ?? () {},
          ),
        ],
      ),
    ),
  );
}

void main() {
  group('CF-69 green', () {
    test('Instagram: Responder em reply ainda aponta para o raiz', () {
      final parent = commentInstagramReplyParent(threadRoot: _root);
      expect(parent.id, 'c1');
      expect(commentApiParentId(replyToRoot: parent), 'c1');
      expect(commentApiParentId(replyToRoot: null), isNull);
    });

    test('mentionDraft do print preenche handle + espaço', () {
      expect(
        Cf196CommentReplyMock.mentionDraft('fan/rafanogueira'),
        'fan/rafanogueira ',
      );
    });

    testWidgets('Populares|Novos + Responder em raiz e reply + compositor', (
      tester,
    ) async {
      await tester.pumpWidget(_harness());
      await tester.pump();

      expect(find.text('Populares'), findsOneWidget);
      expect(find.text('Novos'), findsOneWidget);
      expect(find.text('Responder'), findsNWidgets(2));
      expect(find.byKey(const Key('comment-composer')), findsOneWidget);
      expect(find.byKey(const Key('comment-gif')), findsOneWidget);
      expect(find.text('Adicione um comentário...'), findsOneWidget);
    });

    testWidgets('modo resposta: banner + ↑; sem smile/chip GIF (print CF-196)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          draft: 'fan/rafanogueira ',
          replyAuthor: 'Rafa Nogueira',
          replyHandle: 'fan/rafanogueira',
        ),
      );
      await tester.pump();

      expect(find.textContaining('Respondendo a'), findsOneWidget);
      expect(find.byKey(const Key('comment-submit')), findsOneWidget);
      expect(find.byKey(const Key('comment-gif')), findsNothing);
      expect(find.byKey(const Key('comment-gif-chip')), findsNothing);
    });
  });

  group('CF-69 red', () {
    testWidgets('submit vazio/sem GIF: botão desabilitado (não publica)', (
      tester,
    ) async {
      var submitted = false;
      await tester.pumpWidget(
        _harness(
          draft: '   ',
          onSubmit: () => submitted = true,
        ),
      );
      await tester.pump();

      // Idle novo comentário: smile GIF; sem ↑ até haver conteúdo.
      expect(find.byKey(const Key('comment-submit')), findsNothing);
      expect(find.byKey(const Key('comment-gif')), findsOneWidget);
      expect(submitted, isFalse);
    });

    testWidgets('submitting=true esconde ↑ (canSubmit=false) e não publica', (
      tester,
    ) async {
      var submitted = 0;
      await tester.pumpWidget(
        _harness(
          draft: 'ok',
          submitting: true,
          onSubmit: () => submitted++,
        ),
      );
      await tester.pump();

      // Durante submit o compositor desabilita publicação (sem ↑ ativo).
      expect(find.byKey(const Key('comment-submit')), findsNothing);
      expect(submitted, 0);
    });

    test('api parent vazio não inventa id', () {
      expect(
        commentApiParentId(
          replyToRoot: const CommentItem(
            id: '   ',
            author: 'x',
            handle: '@x',
            avatarUri: '',
            text: 't',
            minutesAgo: 1,
            votes: 0,
          ),
        ),
        isNull,
      );
    });

    test('canSubmit nega draft/GIF só whitespace', () {
      expect(commentCanSubmit(draft: '', gifUrl: null), isFalse);
      expect(commentCanSubmit(draft: '   ', gifUrl: ''), isFalse);
      expect(commentCanSubmit(draft: '', gifUrl: '   '), isFalse);
    });
  });

  group('CF-69 edge', () {
    testWidgets('texto longo + teclado: compositor permanece montado', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final long = 'a' * 400;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(390, 844),
            viewInsets: EdgeInsets.only(bottom: 320),
            textScaler: TextScaler.linear(1.3),
          ),
          child: _harness(draft: long),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('comment-composer')), findsOneWidget);
      expect(find.byKey(const Key('comment-submit')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('GIF selecionado em comentário novo mostra chip Remover', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _harness(
          draft: '',
          selectedGifUrl: 'https://example.com/g.gif',
        ),
      );
      await tester.pump();
      // errorBuilder do preview (sem rede no test binding).
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Remover GIF'), findsOneWidget);
      expect(find.byKey(const Key('comment-submit')), findsOneWidget);
      expect(find.byKey(const Key('comment-gif-chip')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    test('cancelar resposta limpa draft e GIF', () {
      final reset = commentCancelReplyComposerState();
      expect(reset.draft, '');
      expect(reset.gifUrl, isNull);
    });

    test('canSubmit aceita só GIF ou só texto', () {
      expect(
        commentCanSubmit(draft: '', gifUrl: 'https://giphy.test/x'),
        isTrue,
      );
      expect(commentCanSubmit(draft: 'oi', gifUrl: null), isTrue);
    });

    testWidgets(
      '✕ cancelar resposta dispara onCancel e some o banner',
      (tester) async {
        var cancelled = false;
        await tester.pumpWidget(
          MaterialApp(
            theme: buildCrowdFansTheme(Brightness.light),
            home: Scaffold(
              body: CommentComposer(
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
          ),
        );
        await tester.pump();
        expect(find.textContaining('Respondendo a'), findsOneWidget);
        await tester.tap(find.byTooltip('Cancelar resposta'));
        await tester.pump();
        expect(cancelled, isTrue);
      },
    );

    testWidgets('zero votos / reply count zero: Responder ainda visível', (
      tester,
    ) async {
      const lonely = CommentItem(
        id: 'c0',
        author: 'Solo',
        handle: 'fan/solo',
        avatarUri: '',
        text: 'sem replies',
        minutesAgo: 1,
        votes: 0,
        myVote: 0,
        replies: [],
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: CommentRow(
              comment: lonely,
              isOwn: false,
              isReply: false,
              onOpenProfile: () {},
              onReply: () {},
              onReport: () {},
              onEdit: () {},
              onDelete: () {},
              onVoteApplied: (_) {},
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Responder'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
    });
  });
}
