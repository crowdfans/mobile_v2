import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Tile da grade Copiar Link / WhatsApp / Stories no share sheet.
class PostShareActionTile extends StatelessWidget {
  const PostShareActionTile({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.iconWidget,
    this.iconColor,
    this.labelColor,
  }) : assert(icon != null || iconWidget != null);

  final String label;
  final IconData? icon;
  final Widget? iconWidget;
  final VoidCallback onPressed;
  final Color? iconColor;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: colors.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 88),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  iconWidget ??
                      Icon(
                        icon,
                        size: 28,
                        color: iconColor ?? colors.textPrimary,
                      ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: labelColor ?? colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
