import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:flutter/material.dart';

/// Setas de voto (UI; persistência entra no `VoteService`).
class VoteControl extends StatelessWidget {
  const VoteControl({super.key, required this.post});

  final FeedPost post;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Row(
      children: [
        Icon(Icons.keyboard_arrow_up, color: colors.icon),
        Text(
          '${post.votes}',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        Icon(Icons.keyboard_arrow_down, color: colors.icon),
      ],
    );
  }
}
