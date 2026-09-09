import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Ícone roxo da barra de mídia do Novo Post.
class NovoPostMediaToolbarButton extends StatelessWidget {
  const NovoPostMediaToolbarButton({
    super.key,
    required this.asset,
    required this.onPressed,
  });

  final String asset;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return IconButton(
      onPressed: onPressed,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      icon: SvgPicture.asset(
        asset,
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(colors.primary, BlendMode.srcIn),
      ),
    );
  }
}
