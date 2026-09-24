import 'package:crowdfans/components/comments/comment_composer.dart';
import 'package:crowdfans/components/comments/comment_row.dart';
import 'package:crowdfans/components/comments/comment_sort_chip.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/comment_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CF-69: Populares|Novos, compositor sticky+GIF, Responder em reply', (
    tester,
  ) async {
    const nested = CommentItem(
      id: 'r1',
      author: 'Fã 2',
      handle: '@fan2',
      avatarUri: '',
      text: 'resposta',
      minutesAgo: 1,
      votes: 0,
      myVote: 0,
      parentCommentId: 'c1',
      replies: [],
    );
    const root = CommentItem(
      id: 'c1',
      author: 'Fã 1',
      handle: '@fan1',
      avatarUri: '',
      text: 'raiz',
      minutesAgo: 2,
      votes: 3,
      myVote: 0,
      replies: [nested],
    );

    await tester.pumpWidget(
      MaterialApp(
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
                replyAuthor: 'Fã 2',
                replyHandle: '@fan2',
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

    expect(find.text('Populares'), findsOneWidget);
    expect(find.text('Novos'), findsOneWidget);
    expect(find.byKey(const Key('comment-gif')), findsOneWidget);
    expect(find.byKey(const Key('comment-submit')), findsOneWidget);
    // Responder no raiz e na resposta aninhada (sem cadeia Twitter).
    expect(find.text('Responder'), findsNWidgets(2));
  });
}
