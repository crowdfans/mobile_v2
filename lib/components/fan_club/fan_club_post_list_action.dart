import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Linha de ação full-width do menu de post do fã-clube (favoritar / reportar).
class FanClubPostListAction extends StatelessWidget {
  const FanClubPostListAction({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.svgAsset,
    this.backgroundColor,
    this.foregroundColor,
    this.danger = false,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final String? svgAsset;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final fg = foregroundColor ?? (danger ? colors.danger : colors.textPrimary);
    final bg = backgroundColor ??
        (danger ? AppPalette.red100.withValues(alpha: 0.55) : colors.surfaceAlt);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                if (svgAsset != null)
                  SvgPicture.asset(
                    svgAsset!,
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(fg, BlendMode.srcIn),
                  )
                else if (icon != null)
                  Icon(icon, size: 24, color: fg),
                if (svgAsset != null || icon != null) const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: fg,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
