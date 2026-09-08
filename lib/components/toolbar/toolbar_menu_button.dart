import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Botão de menu da toolbar (hambúrguer SVG).
class ToolbarMenuButton extends StatelessWidget {
  const ToolbarMenuButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return IconButton(
      onPressed: onPressed,
      tooltip: 'Menu',
      icon: SvgPicture.asset(
        'assets/icons/General/menu-02.svg',
        width: 22,
        height: 22,
        colorFilter: ColorFilter.mode(colors.textPrimary, BlendMode.srcIn),
      ),
    );
  }
}
