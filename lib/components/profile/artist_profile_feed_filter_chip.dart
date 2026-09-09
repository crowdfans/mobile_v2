import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Filtro Todos / Posts / Mídia na aba Feed.
class ArtistProfileFeedFilterChip extends StatelessWidget {
  const ArtistProfileFeedFilterChip({
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(color: selected ? colors.primary : colors.border),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
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
