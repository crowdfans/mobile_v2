import 'package:crowdfans/components/buttons/app_icon_button.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Aba SVG da bottom nav (home, clubes, +, buscar).
class BottomNavSvgTab extends StatelessWidget {
  const BottomNavSvgTab({
    super.key,
    required this.asset,
    required this.selected,
    required this.onTap,
    required this.semanticLabel,
    this.showIndicator = true,
  });

  final String asset;
  final bool selected;
  final VoidCallback onTap;
  final String semanticLabel;
  final bool showIndicator;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final tint = selected ? colors.primary : colors.textTertiary;
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 3,
            color: showIndicator && selected
                ? colors.primary
                : Colors.transparent,
          ),
          const SizedBox(height: 10),
          AppIconButton(
            asset: asset,
            onPressed: onTap,
            color: tint,
            semanticLabel: semanticLabel,
          ),
        ],
      ),
    );
  }
}
