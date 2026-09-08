import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Chip de aba do perfil de artista.
class ArtistProfileTabChip extends StatelessWidget {
  const ArtistProfileTabChip({
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
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? colors.primary : colors.border),
          color: selected ? colors.surfaceAlt : colors.surface,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? colors.primary : colors.textPrimary,
          ),
        ),
      ),
    );
  }
}
