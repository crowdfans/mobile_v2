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
        color: AppPalette.purple100,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            height: 1.2,
            color: colors.primaryStrong,
          ),
        ),
      ),
    );
  }
}
