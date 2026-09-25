import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Atalho do sheet de opções (fã clube / memórias) — CF-176.
class PostOptionsShortcutCard extends StatelessWidget {
  const PostOptionsShortcutCard({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.asset,
    this.icon,
    this.iconColor,
    this.labelColor,
  });

  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final String? asset;
  final IconData? icon;
  final Color? iconColor;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Expanded(
      child: Material(
        color: backgroundColor ?? colors.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 96),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (asset != null)
                    Image.asset(
                      asset!,
                      width: 40,
                      height: 40,
                      errorBuilder: (_, _, _) => Icon(
                        icon ?? Icons.image,
                        size: 40,
                        color: iconColor ?? colors.primaryStrong,
                      ),
                    )
                  else if (icon != null)
                    Icon(
                      icon,
                      size: 40,
                      color: iconColor ?? colors.primaryStrong,
                    ),
                  if (asset != null || icon != null) const SizedBox(height: 10),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
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
