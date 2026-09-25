import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Indicador compacto “Modo secreto ativo” (CF-177) — pílula, não faixa.
class NovoPostSecretBanner extends StatelessWidget {
  const NovoPostSecretBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppPalette.blue50,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 5, 12, 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/icons/General/eye-off.svg',
                width: 14,
                height: 14,
                colorFilter: const ColorFilter.mode(
                  AppPalette.blue700,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 6),
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
      ),
    );
  }
}
