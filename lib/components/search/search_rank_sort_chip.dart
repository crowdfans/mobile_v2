import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Chip Crescente / Decrescente do ranking Top 500.
class SearchRankSortChip extends StatelessWidget {
  const SearchRankSortChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Material(
      color: selected ? const Color(0xFF1C1C1E) : colors.surface,
      shape: StadiumBorder(
        side: BorderSide(color: selected ? const Color(0xFF1C1C1E) : colors.border),
      ),
      child: InkWell(
        onTap: onPressed,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : colors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
