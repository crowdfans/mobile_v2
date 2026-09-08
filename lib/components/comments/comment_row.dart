import 'package:crowdfans/components/home/vote_control_bar.dart';
import 'package:crowdfans/components/post/post_avatar.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/comment_service.dart';
import 'package:crowdfans/services/vote_service.dart';
import 'package:flutter/material.dart';

/// Linha de um comentário (ou resposta) com voto e ações.
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

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: isReply ? 28 : 0,
        bottom: isReply ? 10 : 16,
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
                GestureDetector(
                  onTap: onOpenProfile,
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          comment.author,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${comment.minutesAgo}m',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (comment.text.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    comment.text,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: colors.textPrimary,
                    ),
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
                const SizedBox(height: 6),
                VoteControlBar(
                  votes: comment.votes,
                  myVote: comment.myVote,
                  onVote: (direction) =>
                      VoteService.voteComment(comment.id, direction),
                  onVoteApplied: onVoteApplied,
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 16,
                  children: [
                    if (!isReply)
                      GestureDetector(
                        onTap: onReply,
                        child: Text(
                          'Responder',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colors.primary,
                          ),
                        ),
                      ),
                    if (!isOwn)
                      GestureDetector(
                        onTap: onReport,
                        child: Text(
                          'Denunciar',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                    if (isOwn)
                      GestureDetector(
                        onTap: onEdit,
                        child: Text(
                          'Editar',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colors.primary,
                          ),
                        ),
                      ),
                    if (isOwn)
                      GestureDetector(
                        onTap: onDelete,
                        child: Text(
                          'Excluir',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colors.textSecondary,
                          ),
                        ),
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
