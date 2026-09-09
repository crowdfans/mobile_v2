import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Pill "Modo secreto ativo" abaixo do header.
class NovoPostSecretBanner extends StatelessWidget {
  const NovoPostSecretBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppPalette.blue50,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppPalette.blue200),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppPalette.blue300, AppPalette.blue50],
                ),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppPalette.blue200),
              ),
              child: SizedBox(
                width: 18,
                height: 18,
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/General/eye-off.svg',
                    width: 12,
                    height: 12,
                    colorFilter: const ColorFilter.mode(
                      AppPalette.blue700,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Modo secreto ativo',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppPalette.blue700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
