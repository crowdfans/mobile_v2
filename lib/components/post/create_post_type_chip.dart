import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:flutter/material.dart';

/// Chip de tipo no formulário de criar/editar post.
class CreatePostTypeChip extends StatelessWidget {
  const CreatePostTypeChip({
    super.key,
    required this.type,
    required this.selected,
    required this.onPressed,
  });

  final PostType type;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Material(
      color: selected ? colors.primary : colors.inputBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: selected ? colors.primary : colors.inputBorder),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            postTypeLabel(type),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: selected ? colors.background : colors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
