import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Selo `#[posição]` do artista no card do post.
///
/// CF-131 print: pill cinza compacta (não lilás).
class PostRankBadge extends StatelessWidget {
  const PostRankBadge({super.key, required this.rank});

  final String rank;

  @override
  Widget build(BuildContext context) {
    final label = rank.startsWith('#') ? rank : '#$rank';
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppPalette.platinum100,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            height: 1.2,
            color: AppPalette.platinum600,
          ),
        ),
      ),
    );
  }
}
