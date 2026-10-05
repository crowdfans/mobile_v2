import 'package:crowdfans/components/comments/comment_composer.dart';
import 'package:crowdfans/components/comments/comment_reply_banner.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrapComposer({
  required CommentComposer child,
  double keyboardInset = 0,
  double safeBottom = 0,
}) {
  return MaterialApp(
    theme: buildCrowdFansTheme(Brightness.light),
    builder: (context, childWidget) {
      return MediaQuery(
        data: MediaQueryData(
          viewInsets: EdgeInsets.only(bottom: keyboardInset),
          padding: EdgeInsets.only(bottom: safeBottom),
        ),
        child: childWidget!,
      );
    },
    home: Scaffold(
      resizeToAvoidBottomInset: false,
      body: Align(alignment: Alignment.bottomCenter, child: child),
    ),
  );
}

void main() {
  group('CF-196 green', () {
    testWidgets(
      'faixa de resposta anunciada, prefill fan/, compositor sobe com teclado',
      (tester) async {
        var cancelled = false;
        final draft = Cf196CommentReplyMock.mentionDraft(
          Cf196CommentReplyMock.replyHandle,
        );

        await tester.pumpWidget(
          _wrapComposer(
            keyboardInset: Cf196CommentReplyMock.keyboardInset,
            child: CommentComposer(
              draft: draft,
              replyAuthor: Cf196CommentReplyMock.replyAuthor,
              replyHandle: Cf196CommentReplyMock.replyHandle,
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

        expect(find.byType(CommentReplyBanner), findsOneWidget);
        expect(
          find.textContaining('Respondendo a Rafa Nogueira'),
          findsOneWidget,
        );
        expect(find.textContaining('fan/rafanogueira'), findsWidgets);
        expect(find.byKey(const Key('comment-submit')), findsOneWidget);
        // Print CF-196 (resposta): só ↑ — sem chip GIF ao lado.
        expect(find.byKey(const Key('comment-gif-chip')), findsNothing);
        expect(find.byKey(const Key('comment-gif')), findsNothing);

        final padding = tester.widget<AnimatedPadding>(
          find.byType(AnimatedPadding),
        );
        expect(
          (padding.padding as EdgeInsets).bottom,
          Cf196CommentReplyMock.keyboardInset,
        );

        await tester.tap(find.byTooltip('Cancelar resposta'));
        await tester.pump();
        expect(cancelled, isTrue);
      },
    );

    test('mentionDraft do print = fan/rafanogueira + espaço', () {
      expect(
        Cf196CommentReplyMock.mentionDraft('fan/rafanogueira'),
        'fan/rafanogueira ',
      );
      expect(kUseCf196CommentMocks, isFalse);
    });
  });

  group('CF-196 red', () {
    testWidgets('sem resposta: sem faixa; idle = smile; submit ausente', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrapComposer(
          keyboardInset: 280,
          child: CommentComposer(
            draft: '',
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
        ),
      );
      await tester.pump();

      expect(find.byType(CommentReplyBanner), findsNothing);
      expect(find.textContaining('Respondendo a'), findsNothing);
      expect(find.byKey(const Key('comment-gif')), findsOneWidget);
      expect(find.byKey(const Key('comment-submit')), findsNothing);
      expect(find.text('Adicione um comentário...'), findsOneWidget);
    });

    testWidgets('rascunho vazio + resposta: enviar desabilitado (Semantics)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrapComposer(
          child: CommentComposer(
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

      final submit = find.byKey(const Key('comment-submit'));
      expect(submit, findsOneWidget);
      final ink = tester.widget<InkWell>(submit);
      expect(ink.onTap, isNull);
    });
  });

  group('CF-196 edge', () {
    test('mentionDraft: vazio, @ e handle sem prefixo', () {
      expect(Cf196CommentReplyMock.mentionDraft(null), '');
      expect(Cf196CommentReplyMock.mentionDraft(''), '');
      expect(Cf196CommentReplyMock.mentionDraft('   '), '');
      expect(Cf196CommentReplyMock.mentionDraft('@ponzanelli'), '@ponzanelli ');
      expect(
        Cf196CommentReplyMock.mentionDraft('rafanogueira'),
        'fan/rafanogueira ',
      );
    });

    testWidgets('sem teclado: padding = safe bottom (não some o compositor)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrapComposer(
          keyboardInset: 0,
          safeBottom: 34,
          child: CommentComposer(
            draft: '',
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
        ),
      );
      await tester.pump();

      final padding = tester.widget<AnimatedPadding>(
        find.byType(AnimatedPadding),
      );
      expect((padding.padding as EdgeInsets).bottom, 34);
    });

    testWidgets('autor longo: faixa + cancelar continuam acessíveis', (
      tester,
    ) async {
      const long =
          'Maria Clara da Silva Souza Oliveira Fernandes Nogueira Extra';
      await tester.pumpWidget(
        _wrapComposer(
          keyboardInset: 200,
          child: CommentComposer(
            draft: 'fan/maria ',
            replyAuthor: long,
            replyHandle: 'fan/mariaclara',
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

      expect(find.byTooltip('Cancelar resposta'), findsOneWidget);
      expect(find.textContaining('Respondendo a'), findsOneWidget);
      expect(find.byKey(const Key('comment-gif-chip')), findsNothing);
    });
  });
}
