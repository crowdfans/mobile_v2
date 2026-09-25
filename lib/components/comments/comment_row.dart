import 'package:crowdfans/components/home/vote_control_bar.dart';
import 'package:crowdfans/components/post/post_avatar.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/comment_service.dart';
import 'package:crowdfans/services/vote_service.dart';
import 'package:crowdfans/utils/relative_time.dart';
import 'package:flutter/material.dart';

/// Linha de um comentário (ou resposta) — layout do print CF-194.
class CommentRow extends StatelessWidget {
  const CommentRow({
    super.key,
    required this.comment,
    required this.isOwn,
    required this.isReply,
    required this.onOpenProfile,
    required this.onReply,
    required this.onReport,
    required this.onEdit,
    required this.onDelete,
    required this.onVoteApplied,
    this.replyToHandle,
  });

  final CommentItem comment;
  final bool isOwn;
  final bool isReply;
  final VoidCallback onOpenProfile;
  final VoidCallback onReply;
  final VoidCallback onReport;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<VoteResult> onVoteApplied;

  /// Handle do comentário pai (menção roxa no início da resposta).
  final String? replyToHandle;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final handle = comment.handle.trim();
    return Padding(
      padding: EdgeInsets.only(
        left: isReply ? 28 : 0,
        bottom: isReply ? 8 : 14,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onOpenProfile,
            child: PostAvatar(url: comment.avatarUri, size: 36),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: onOpenProfile,
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                comment.author,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ),
                            if (handle.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  handle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colors.textTertiary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.more_vert,
                        size: 20,
                        color: colors.textTertiary,
                      ),
                      onSelected: (value) {
                        switch (value) {
                          case 'report':
                            onReport();
                          case 'edit':
                            onEdit();
                          case 'delete':
                            onDelete();
                        }
                      },
                      itemBuilder: (context) => [
                        if (!isOwn)
                          const PopupMenuItem(
                            value: 'report',
                            child: Text('Denunciar'),
                          ),
                        if (isOwn) ...[
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Editar'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Excluir'),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                Text(
                  formatMinutesAgo(comment.minutesAgo),
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.textTertiary,
                  ),
                ),
                if (comment.text.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _CommentBody(
                    text: comment.text,
                    mentionHandle: isReply ? replyToHandle : null,
                  ),
                ],
                if (comment.gifUrl != null && comment.gifUrl!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      comment.gifUrl!,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: onReply,
                      child: Text(
                        'Responder',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    VoteControlBar(
                      votes: comment.votes,
                      myVote: comment.myVote,
                      onVote: (direction) =>
                          VoteService.voteComment(comment.id, direction),
                      onVoteApplied: onVoteApplied,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentBody extends StatelessWidget {
  const _CommentBody({required this.text, this.mentionHandle});

  final String text;
  final String? mentionHandle;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final bodyStyle = TextStyle(
      fontSize: 14,
      height: 1.4,
      color: colors.textPrimary,
    );
    final mention = (mentionHandle ?? '').trim();
    if (mention.isEmpty) {
      return Text(text, style: bodyStyle);
    }
    final normalized = mention.startsWith('@') ? mention.substring(1) : mention;
    final alreadyPrefixed = text.trimLeft().startsWith(mention) ||
        text.trimLeft().startsWith('@$normalized') ||
        text.trimLeft().startsWith(normalized);
    if (alreadyPrefixed) {
      // Destaca a menção no início se o texto já a contém.
      final trimmed = text.trimLeft();
      String lead;
      String rest;
      if (trimmed.startsWith(mention)) {
        lead = mention;
        rest = trimmed.substring(mention.length).trimLeft();
      } else if (trimmed.startsWith('@$normalized')) {
        lead = '@$normalized';
        rest = trimmed.substring(normalized.length + 1).trimLeft();
      } else {
        lead = normalized;
        rest = trimmed.substring(normalized.length).trimLeft();
      }
      return Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: lead,
              style: bodyStyle.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (rest.isNotEmpty) TextSpan(text: ' $rest', style: bodyStyle),
          ],
        ),
      );
    }
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: mention,
            style: bodyStyle.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(text: ' $text', style: bodyStyle),
        ],
      ),
    );
  }
}
