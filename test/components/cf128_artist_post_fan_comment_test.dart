import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/comments/comment_composer.dart';
import 'package:crowdfans/components/post/post_card_footer.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:crowdfans/screens/post/create_post_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// CF-128 — green / red / edge do fluxo artista posta + superfã comenta.
///
/// Patrol E2E (device) fica em `integration_test/e2e_artist_post_fan_comment_test.dart`.
/// Aqui cobrimos as gates de UI/keys sem emulador.
void main() {
  FeedPost samplePost({int comments = 0, String text = 'load-e2e stamp'}) {
    return FeedPost(
      id: 'post-cf128',
      type: PostType.text,
      author: 'Artista E2E',
      handle: '@artist/e2e',
      minutesAgo: 1,
      avatarUri: '',
      text: text,
      votes: 0,
      comments: comments,
      shares: 0,
      artistId: 'artist-uid',
    );
  }

  Widget wrap(Widget child) {
    return MaterialApp(
      theme: buildCrowdFansTheme(Brightness.light),
      home: Scaffold(body: child),
    );
  }

  group('CF-128 GREEN', () {
    test('canPublishCreatePost com texto válido', () {
      expect(
        canPublishCreatePost(text: 'e2e-post-1', hasMedia: false),
        isTrue,
      );
    });

    testWidgets('composer com rascunho habilita comment-submit', (tester) async {
      var submitted = false;
      await tester.pumpWidget(
        wrap(
          CommentComposer(
            draft: 'e2e-cmt-ok',
            replyAuthor: null,
            editing: false,
            selectedGifUrl: null,
            submitting: false,
            onDraftChanged: (_) {},
            onCancelEdit: () {},
            onCancelReply: () {},
            onRemoveGif: () {},
            onPickGif: () {},
            onSubmit: () => submitted = true,
          ),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('comment-composer')), findsOneWidget);
      expect(find.byKey(const Key('comment-submit')), findsOneWidget);

      await tester.tap(find.byKey(const Key('comment-submit')));
      await tester.pump();
      expect(submitted, isTrue);
    });

    testWidgets('post-comments key abre callback do footer', (tester) async {
      var opened = false;
      await tester.pumpWidget(
        wrap(
          PostCardFooter(
            post: samplePost(comments: 2),
            onOpenComments: () => opened = true,
          ),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('post-comments')), findsOneWidget);
      await tester.tap(find.byKey(const Key('post-comments')));
      await tester.pump();
      expect(opened, isTrue);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('create-post-submit habilitado com texto', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        wrap(
          AppButton(
            key: const Key('create-post-submit'),
            label: 'Publicar Post',
            disabled: !canPublishCreatePost(text: 'load-e2e ok', hasMedia: false),
            onPressed: () => pressed = true,
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.byKey(const Key('create-post-submit')));
      await tester.pump();
      expect(pressed, isTrue);
    });
  });

  group('CF-128 RED', () {
    test('canPublishCreatePost bloqueia vazio', () {
      expect(canPublishCreatePost(text: '', hasMedia: false), isFalse);
      expect(canPublishCreatePost(text: '   ', hasMedia: false), isFalse);
    });

    testWidgets('composer idle: comment-submit ausente', (tester) async {
      var submitted = false;
      await tester.pumpWidget(
        wrap(
          CommentComposer(
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
            onSubmit: () => submitted = true,
          ),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('comment-composer')), findsOneWidget);
      expect(find.byKey(const Key('comment-submit')), findsNothing);
      expect(submitted, isFalse);
    });

    testWidgets('create-post-submit desabilitado sem conteúdo', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        wrap(
          AppButton(
            key: const Key('create-post-submit'),
            label: 'Publicar Post',
            disabled: !canPublishCreatePost(text: '', hasMedia: false),
            onPressed: () => pressed = true,
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.byKey(const Key('create-post-submit')));
      await tester.pump();
      expect(pressed, isFalse);
    });
  });

  group('CF-128 EDGE', () {
    test('canPublishCreatePost limite 280 e mídia sem texto', () {
      expect(
        canPublishCreatePost(text: 'a' * 280, hasMedia: false),
        isTrue,
      );
      expect(
        canPublishCreatePost(text: 'a' * 281, hasMedia: false),
        isFalse,
      );
      expect(
        canPublishCreatePost(text: '', hasMedia: true),
        isTrue,
      );
    });

    testWidgets('composer com teclado sobe (viewInsets)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          builder: (context, child) {
            return MediaQuery(
              data: const MediaQueryData(
                viewInsets: EdgeInsets.only(bottom: 280),
              ),
              child: child!,
            );
          },
          home: Scaffold(
            resizeToAvoidBottomInset: false,
            body: Align(
              alignment: Alignment.bottomCenter,
              child: CommentComposer(
                draft: 'longo-${'x' * 200}',
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
          ),
        ),
      );
      await tester.pump();

      final padding = tester.widget<AnimatedPadding>(
        find.byType(AnimatedPadding),
      );
      expect((padding.padding as EdgeInsets).bottom, 280);
      expect(find.byKey(const Key('comment-submit')), findsOneWidget);
    });

    testWidgets('footer com zero comentários ainda expõe post-comments', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          PostCardFooter(
            post: samplePost(comments: 0),
            onOpenComments: () {},
          ),
        ),
      );
      await tester.pump();
      expect(find.byKey(const Key('post-comments')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('post-comments')),
          matching: find.text('0'),
        ),
        findsOneWidget,
      );
    });
  });
}
