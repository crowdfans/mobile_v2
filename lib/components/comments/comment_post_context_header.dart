import 'package:crowdfans/components/home/vote_control_bar.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/vote_service.dart';
import 'package:crowdfans/utils/relative_time.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Contexto do post no topo da tela de comentários (Home e fã-clube).
///
/// CF-194: tempo + texto + votos/compartilhar; título "Comentários" abaixo.
/// Autor/handle ficam no [CommentThreadHeader] (print).
class CommentPostContextHeader extends StatelessWidget {
  const CommentPostContextHeader({
    super.key,
    this.author,
    this.handle,
    this.text,
    this.clubName,
    this.minutesAgo,
    this.votes = 0,
    this.myVote = 0,
    this.shares = 0,
    this.onVote,
    this.onVoteApplied,
    this.onShare,
  });

  final String? author;
  final String? handle;
  final String? text;
  final String? clubName;
  final int? minutesAgo;
  final int votes;
  final int myVote;
  final int shares;
  final Future<VoteResult> Function(VoteDirection direction)? onVote;
  final ValueChanged<VoteResult>? onVoteApplied;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final body = (text ?? '').trim();
    final showLegacyAuthor =
        (author ?? '').trim().isNotEmpty && minutesAgo == null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showLegacyAuthor) ...[
            Text(
              author!.trim(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            if ((handle ?? '').trim().isNotEmpty)
              Text(
                handle!,
                style: TextStyle(fontSize: 13, color: colors.textTertiary),
              ),
            const SizedBox(height: 8),
          ],
          if (minutesAgo != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                formatMinutesAgo(minutesAgo!),
                style: TextStyle(
                  fontSize: 13,
                  color: colors.textTertiary,
                ),
              ),
            ),
          if (body.isNotEmpty)
            Text(
              body,
              style: TextStyle(
                fontSize: 15,
                height: 1.4,
                color: colors.textPrimary,
              ),
            ),
          if (onVote != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                VoteControlBar(
                  votes: votes,
                  myVote: myVote,
                  onVote: onVote!,
                  onVoteApplied: onVoteApplied,
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onShare,
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/Communication/send-03.svg',
                        width: 20,
                        height: 20,
                        colorFilter: ColorFilter.mode(
                          colors.textTertiary,
                          BlendMode.srcIn,
                        ),
                      ),
                      if (shares > 0) ...[
                        const SizedBox(width: 6),
                        Text(
                          '$shares',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Text(
            'Comentários',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
