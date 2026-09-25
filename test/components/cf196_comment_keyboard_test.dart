import 'package:crowdfans/components/comments/comment_composer.dart';
import 'package:crowdfans/components/comments/comment_reply_banner.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'CF-196: faixa de resposta anunciada e compositor sobe com teclado',
    (tester) async {
      var cancelled = false;

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
                draft: '',
                replyAuthor: 'Rafa Nogueira',
                replyHandle: 'rafanogueira',
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
        ),
      );
      await tester.pump();

      expect(find.byType(CommentReplyBanner), findsOneWidget);
      expect(
        find.textContaining('Respondendo a Rafa Nogueira'),
        findsOneWidget,
      );
      expect(find.textContaining('fan/rafanogueira'), findsOneWidget);

      final padding = tester.widget<AnimatedPadding>(
        find.byType(AnimatedPadding),
      );
      expect((padding.padding as EdgeInsets).bottom, 280);

      await tester.tap(find.byTooltip('Cancelar resposta'));
      await tester.pump();
      expect(cancelled, isTrue);
    },
  );
}
