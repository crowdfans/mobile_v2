import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Tile de marca (WhatsApp / Stories) no menu de post do fã-clube.
class FanClubPostShareBrandTile extends StatelessWidget {
  const FanClubPostShareBrandTile({
    super.key,
    required this.label,
    required this.asset,
    required this.fallbackIcon,
    required this.onPressed,
    this.fallbackColor,
  });

  final String label;
  final String asset;
  final IconData fallbackIcon;
  final Color? fallbackColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Material(
      color: colors.surfaceAlt,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                asset,
                width: 28,
                height: 28,
                placeholderBuilder: (_) => Icon(
                  fallbackIcon,
                  size: 28,
                  color: fallbackColor ?? colors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
