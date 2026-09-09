import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Selo `#[posição]` do artista no card do post.
class PostRankBadge extends StatelessWidget {
  const PostRankBadge({super.key, required this.rank});

  final String rank;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final label = rank.startsWith('#') ? rank : '#$rank';
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: colors.primaryStrong,
          ),
        ),
      ),
    );
  }
}
