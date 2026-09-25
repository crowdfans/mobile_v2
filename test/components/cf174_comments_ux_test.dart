import 'package:crowdfans/components/comments/comment_composer.dart';
import 'package:crowdfans/components/comments/comment_post_context_header.dart';
import 'package:crowdfans/components/comments/comment_sort_chip.dart';
import 'package:crowdfans/components/comments/comment_thread_header.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CF-174: contexto do post, chip escuro e compositor compacto', (
    tester,
  ) async {
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
                author: 'Vic Artist',
                handle: '@vic',
                text: 'Post de exemplo',
              ),
              CommentSortChip(
                label: 'Populares',
                selected: true,
                onPressed: () {},
              ),
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
                onSubmit: () {},
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Ponzanelli'), findsOneWidget);
    expect(find.text('@ponzanelli'), findsOneWidget);
    expect(find.text('Voltar'), findsNothing);
    expect(find.text('Vic Artist'), findsOneWidget);
    expect(find.text('Comentários'), findsOneWidget);
    expect(find.byKey(const Key('comment-gif')), findsOneWidget);
    expect(find.byKey(const Key('comment-submit')), findsOneWidget);
    expect(find.text('Publicar'), findsNothing);

    final material = tester.widget<Material>(
      find.descendant(
        of: find.widgetWithText(CommentSortChip, 'Populares'),
        matching: find.byType(Material),
      ),
    );
    expect(material.color, AppPalette.platinum900);
  });
}
