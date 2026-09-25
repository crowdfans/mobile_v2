import 'package:crowdfans/components/comments/comment_composer.dart';
import 'package:crowdfans/components/comments/comment_replies_toggle.dart';
import 'package:crowdfans/components/comments/comment_row.dart';
import 'package:crowdfans/components/comments/comment_sort_chip.dart';
import 'package:crowdfans/components/comments/comment_thread_header.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'CF-195 Home: resposta indentada + Ocultar + Ver N respostas',
    (tester) async {
      final comments = Cf195HomeCommentsMock.comments();
      final root = comments.first;
      final reply = root.replies.first;
      final second = comments[1];

      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: Column(
              children: [
                CommentThreadHeader(
                  onBack: () {},
                  author: Cf195HomeCommentsMock.postAuthor,
                  handle: Cf195HomeCommentsMock.postHandle,
                  avatarUrl: '',
                ),
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
                  child: SingleChildScrollView(
                    child: Column(
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
                          comment: reply,
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
                        CommentRepliesToggle(
                          replyCount: root.replies.length,
                          expanded: true,
                          onToggle: () {},
                        ),
                        CommentRow(
                          comment: second,
                          isOwn: false,
                          isReply: false,
                          onOpenProfile: () {},
                          onReply: () {},
                          onReport: () {},
                          onEdit: () {},
                          onDelete: () {},
                          onVoteApplied: (_) {},
                        ),
                        CommentRepliesToggle(
                          replyCount: second.replies.length,
                          expanded: false,
                          onToggle: () {},
                        ),
                      ],
                    ),
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
      expect(find.textContaining('Fã-clube'), findsNothing);
      expect(find.text('Fê Andrade'), findsOneWidget);
      expect(find.text('Rafa Nogueira'), findsOneWidget);
      expect(find.textContaining('fan/feandrade'), findsWidgets);
      expect(find.text('Ocultar respostas'), findsOneWidget);
      expect(find.text('Ver 2 respostas'), findsOneWidget);
      expect(find.text('Resposta'), findsNothing);
      expect(find.text('Responder'), findsNWidgets(3));
      expect(find.text('Adicione um comentário...'), findsOneWidget);
    },
  );
}
