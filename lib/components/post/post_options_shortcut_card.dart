import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Atalho do sheet de opções (fã clube / memórias).
class PostOptionsShortcutCard extends StatelessWidget {
  const PostOptionsShortcutCard({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.icon,
    this.iconColor,
  });

  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Expanded(
      child: Material(
        color: backgroundColor ?? colors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 72),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: iconColor ?? colors.primaryStrong),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
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
