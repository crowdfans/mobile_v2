import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Linha de lista dos sheets de post (opções / compartilhar).
class PostSheetListItem extends StatelessWidget {
  const PostSheetListItem({
    super.key,
    required this.label,
    required this.onPressed,
    this.showDivider = false,
    this.danger = false,
    this.iconAsset,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final bool showDivider;
  final bool danger;
  final String? iconAsset;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final foreground = danger ? colors.danger : colors.textPrimary;
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
              child: Row(
                children: [
                  if (iconAsset != null) ...[
                    SvgPicture.asset(
                      iconAsset!,
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(
                        foreground,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ] else if (icon != null) ...[
                    Icon(icon, size: 20, color: foreground),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        color: foreground,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
