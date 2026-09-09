import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Chip Todos / Mídia no Meu Perfil.
class MePostsFilterChip extends StatelessWidget {
  const MePostsFilterChip({
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
      color: selected ? colors.surfaceAlt : colors.surface,
      shape: StadiumBorder(
        side: BorderSide(color: selected ? colors.primary : colors.border),
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
              color: colors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
