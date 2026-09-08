import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Linha de lista dos sheets de post (opções / compartilhar).
class PostSheetListItem extends StatelessWidget {
  const PostSheetListItem({
    super.key,
    required this.label,
    required this.onPressed,
    this.showDivider = false,
    this.danger = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool showDivider;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Column(
      children: [
        if (showDivider)
          Divider(height: 1, thickness: 0.5, indent: 16, color: colors.border),
        InkWell(
          onTap: onPressed,
          child: SizedBox(
            height: 52,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    color: danger ? colors.danger : colors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
