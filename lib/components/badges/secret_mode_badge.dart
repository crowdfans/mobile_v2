import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Selo de modo secreto (olho cortado). O artista não vê o post.
class SecretModeBadge extends StatelessWidget {
  const SecretModeBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
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
        width: 24,
        height: 24,
        child: Center(
          child: SvgPicture.asset(
            'assets/icons/General/eye-off.svg',
            width: 16,
            height: 16,
            colorFilter: const ColorFilter.mode(
              AppPalette.blue700,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}
