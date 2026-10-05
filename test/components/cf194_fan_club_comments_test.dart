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

Widget _harness({
  required bool expandedFirst,
  required String draft,
  bool expandSecond = false,
}) {
  final comments = Cf194FanClubCommentsMock.comments();
  final root = comments.first;
  final reply = root.replies.first;
  final second = comments[1];
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
            onMenu: () {},
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
                  if (expandedFirst)
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
                    expanded: expandedFirst,
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
                  if (expandSecond)
                    for (final nested in second.replies)
                      CommentRow(
                        comment: nested,
                        isOwn: false,
                        isReply: true,
                        replyToHandle: second.handle,
                        onOpenProfile: () {},
                        onReply: () {},
                        onReport: () {},
                        onEdit: () {},
                        onDelete: () {},
                        onVoteApplied: (_) {},
                      ),
                  CommentRepliesToggle(
                    replyCount: second.replies.length,
                    expanded: expandSecond,
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
  test('CF-194 fixtures batem o print (Fê+Nina, tempos, votos)', () {
    expect(kUseCf194CommentMocks, isTrue);
    final comments = Cf194FanClubCommentsMock.comments();
    expect(comments, hasLength(2));
    expect(comments.first.author, 'Fê Andrade');
    expect(comments.first.votes, 229);
    expect(comments.first.replies, hasLength(1));
    expect(comments.first.replies.first.author, 'Rafa Nogueira');
    expect(comments.first.replies.first.minutesAgo, 120);
    expect(comments[1].author, 'Nina Costa');
    expect(comments[1].votes, 212);
    expect(comments[1].replies, hasLength(2));
    expect(Cf194FanClubCommentsMock.postVotes, 1039);
    expect(Cf194FanClubCommentsMock.postShares, 20);
  });

  testWidgets('CF-194 recolhido: contexto do clube e Ver respostas', (
    tester,
  ) async {
    const draft = 'rascunho preservado';
    await tester.pumpWidget(_harness(expandedFirst: false, draft: draft));
    await tester.pump();

    expect(find.text('Felipe Rhy'), findsOneWidget);
    expect(find.text('fan/thiagok'), findsOneWidget);
    // Print CF-194: sem badge “Fã-clube · …” no header (só avatar stack).
    expect(find.textContaining('Fã-clube ·'), findsNothing);
    expect(find.byKey(const Key('comment-thread-menu')), findsOneWidget);
    expect(find.text('2 horas atrás'), findsOneWidget);
    expect(find.text(Cf194FanClubCommentsMock.postText), findsOneWidget);
    expect(find.text('Comentários'), findsOneWidget);
    expect(find.text('Populares'), findsOneWidget);
    expect(find.text('Fê Andrade'), findsOneWidget);
    expect(find.text('Nina Costa'), findsOneWidget);
    expect(find.text('Responder'), findsNWidgets(2));
    expect(find.text('Ver 1 respostas'), findsOneWidget);
    expect(find.text('Ver 2 respostas'), findsOneWidget);
    expect(find.text('Rafa Nogueira'), findsNothing);
    expect(find.text('Resposta'), findsNothing);
    expect(find.text('Adicione um comentário...'), findsOneWidget);
    // Com rascunho: enviar + chip GIF (smile idle fica só com campo vazio).
    expect(find.byKey(const Key('comment-gif')), findsNothing);
    expect(find.byKey(const Key('comment-gif-chip')), findsOneWidget);
    expect(find.byKey(const Key('comment-submit')), findsOneWidget);
  });

  testWidgets('CF-194 idle vazio: só emoji no campo, sem enviar', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(expandedFirst: false, draft: ''));
    await tester.pump();

    expect(find.byKey(const Key('comment-gif')), findsOneWidget);
    expect(find.byKey(const Key('comment-submit')), findsNothing);
  });

  testWidgets('CF-194 expandido: menção, Ocultar e rascunho intacto', (
    tester,
  ) async {
    const draft = 'rascunho preservado';
    await tester.pumpWidget(_harness(expandedFirst: true, draft: draft));
    await tester.pump();
    await tester.ensureVisible(find.text('Ocultar respostas'));
    await tester.pump();

    expect(find.text('Ocultar respostas'), findsOneWidget);
    expect(find.text('Rafa Nogueira'), findsOneWidget);
    expect(find.textContaining('fan/feandrade'), findsWidgets);
    expect(find.text('Responder'), findsNWidgets(3));
    expect(find.text('Resposta'), findsNothing);
    expect(find.text('Ver 2 respostas'), findsOneWidget);
    expect(find.text('Nina Costa'), findsOneWidget);
  });
}
