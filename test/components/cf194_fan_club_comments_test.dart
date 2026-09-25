import 'package:crowdfans/components/comments/comment_composer.dart';
import 'package:crowdfans/components/comments/comment_post_context_header.dart';
import 'package:crowdfans/components/comments/comment_replies_toggle.dart';
import 'package:crowdfans/components/comments/comment_row.dart';
import 'package:crowdfans/components/comments/comment_sort_chip.dart';
import 'package:crowdfans/components/comments/comment_thread_header.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/services/vote_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _harness({required bool expanded, required String draft}) {
  final comments = Cf194FanClubCommentsMock.comments();
  final root = comments.first;
  final reply = root.replies.first;
  return MaterialApp(
    theme: buildCrowdFansTheme(Brightness.light),
    home: Scaffold(
      body: Column(
        children: [
          CommentThreadHeader(
            onBack: () {},
            author: Cf194FanClubCommentsMock.postAuthor,
            handle: Cf194FanClubCommentsMock.postHandle,
            clubName: Cf194FanClubCommentsMock.clubName,
            avatarUrl: '',
            clubAvatarUrl: '',
          ),
          CommentPostContextHeader(
            text: Cf194FanClubCommentsMock.postText,
            minutesAgo: Cf194FanClubCommentsMock.postMinutesAgo,
            votes: Cf194FanClubCommentsMock.postVotes,
            shares: Cf194FanClubCommentsMock.postShares,
            onVote: (_) async =>
                const VoteResult(id: 'p1', votes: 1039, myVote: 0),
            onShare: () {},
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
                  if (expanded)
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
                    expanded: expanded,
                    onToggle: () {},
                  ),
                ],
              ),
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
  testWidgets('CF-194 recolhido: contexto do clube e Ver respostas', (
    tester,
  ) async {
    const draft = 'rascunho preservado';
    await tester.pumpWidget(_harness(expanded: false, draft: draft));
    await tester.pump();

    expect(find.text('Felipe Rhy'), findsOneWidget);
    expect(find.text('fan/thiagok'), findsOneWidget);
    expect(find.textContaining('Fã-clube · Thiago K'), findsOneWidget);
    expect(find.text('2 horas atrás'), findsOneWidget);
    expect(find.text(Cf194FanClubCommentsMock.postText), findsOneWidget);
    expect(find.text('Comentários'), findsOneWidget);
    expect(find.text('Populares'), findsOneWidget);
    expect(find.text('Fê Andrade'), findsOneWidget);
    expect(find.text('Responder'), findsOneWidget);
    expect(find.text('Ver 1 resposta'), findsOneWidget);
    expect(find.text('Rafa Nogueira'), findsNothing);
    expect(find.text('Resposta'), findsNothing);
    expect(find.text('Adicione um comentário...'), findsOneWidget);
  });

  testWidgets('CF-194 expandido: menção, Ocultar e rascunho intacto', (
    tester,
  ) async {
    const draft = 'rascunho preservado';
    await tester.pumpWidget(_harness(expanded: true, draft: draft));
    await tester.pump();
    await tester.ensureVisible(find.text('Ocultar respostas'));
    await tester.pump();

    expect(find.text('Ocultar respostas'), findsOneWidget);
    expect(find.text('Rafa Nogueira'), findsOneWidget);
    expect(find.textContaining('fan/feandrade'), findsWidgets);
    expect(find.text('Responder'), findsNWidgets(2));
    expect(find.text('Resposta'), findsNothing);
  });
}
