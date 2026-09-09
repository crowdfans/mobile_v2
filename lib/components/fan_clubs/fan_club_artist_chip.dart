import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Chip de artista (ou Todos) na aba Clubes.
class FanClubArtistChip extends StatelessWidget {
  const FanClubArtistChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onPressed,
    this.onLongPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;
  final VoidCallback? onLongPressed;

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
        onLongPress: onLongPressed,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? colors.buttonPrimaryText : colors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
