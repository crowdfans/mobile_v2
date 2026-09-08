import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Botão quadrado com SVG (espelho do `AppIconButtonComponent`).
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.asset,
    required this.onPressed,
    required this.color,
    this.size = 40,
    this.iconSize = 26,
    this.semanticLabel,
  });

  final String asset;
  final VoidCallback onPressed;
  final Color color;
  final double size;
  final double iconSize;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        tooltip: semanticLabel,
        icon: SvgPicture.asset(
          asset,
          width: iconSize,
          height: iconSize,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          semanticsLabel: semanticLabel,
        ),
      ),
    );
  }
}
