import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Linha do menu (+) da bottom nav.
class CreateMenuItemButton extends StatelessWidget {
  const CreateMenuItemButton({
    super.key,
    required this.asset,
    required this.label,
    required this.onPressed,
    this.showDivider = false,
  });

  final String asset;
  final String label;
  final VoidCallback onPressed;
  final bool showDivider;

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
            height: 60,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  SvgPicture.asset(
                    asset,
                    width: 21,
                    height: 21,
                    colorFilter: ColorFilter.mode(colors.icon, BlendMode.srcIn),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      height: 20 / 16,
                      color: colors.textPrimary,
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
