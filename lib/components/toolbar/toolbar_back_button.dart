import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Botão voltar da toolbar (chevron SVG).
class ToolbarBackButton extends StatelessWidget {
  const ToolbarBackButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return IconButton(
      onPressed: onPressed,
      tooltip: 'Voltar',
      icon: SvgPicture.asset(
        'assets/icons/arrows/chevron-left.svg',
        width: 20,
        height: 20,
        colorFilter: ColorFilter.mode(colors.textPrimary, BlendMode.srcIn),
      ),
    );
  }
}
