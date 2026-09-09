import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Chip Populares / Novos na tela de comentários.
class CommentSortChip extends StatelessWidget {
  const CommentSortChip({
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
      color: selected ? colors.primary : colors.surface,
      shape: StadiumBorder(
        side: BorderSide(color: selected ? colors.primary : colors.border),
      ),
      child: InkWell(
        onTap: onPressed,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? colors.buttonPrimaryText : colors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
