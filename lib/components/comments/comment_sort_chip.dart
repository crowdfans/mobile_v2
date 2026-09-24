import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Chip Populares / Novos — selecionado usa variante escura (CF-174).
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
    final bg = selected ? AppPalette.platinum900 : colors.surface;
    final fg = selected ? AppPalette.platinum50 : colors.textPrimary;
    return Material(
      color: bg,
      shape: StadiumBorder(
        side: BorderSide(color: selected ? bg : colors.border),
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
              color: fg,
            ),
          ),
        ),
      ),
    );
  }
}
