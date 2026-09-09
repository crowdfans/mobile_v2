import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Botão do olho cortado no topo do Novo Post (ativa/desativa modo secreto).
class SecretModeToggleButton extends StatelessWidget {
  const SecretModeToggleButton({
    super.key,
    required this.active,
    this.onPressed,
  });

  final bool active;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('novo-post-secret-toggle'),
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: active
                  ? const [AppPalette.blue300, AppPalette.blue50]
                  : const [AppPalette.blue50, AppPalette.blue50],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: active ? AppPalette.blue200 : AppPalette.blue200,
            ),
          ),
          child: SizedBox(
            width: 32,
            height: 32,
            child: Center(
              child: SvgPicture.asset(
                'assets/icons/General/eye-off.svg',
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(
                  active ? AppPalette.blue700 : AppPalette.blue700.withValues(alpha: 0.55),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
