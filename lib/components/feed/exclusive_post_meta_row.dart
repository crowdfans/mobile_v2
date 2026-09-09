import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Faixa/badge de post exclusivo (print Artista Feed Home CF-111).
class ExclusivePostMetaRow extends StatelessWidget {
  const ExclusivePostMetaRow({
    super.key,
    required this.memberName,
    required this.unlocked,
    this.onPressUnlock,
  });

  final String memberName;
  final bool unlocked;
  final VoidCallback? onPressUnlock;

  @override
  Widget build(BuildContext context) {
    if (unlocked) {
      return Align(
        alignment: Alignment.centerLeft,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppPalette.purple100,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/icons/Media & devices/music-note-01.svg',
                  width: 14,
                  height: 14,
                  colorFilter: const ColorFilter.mode(
                    AppPalette.purple700,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Exclusivo',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.purple700,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppPalette.purple50,
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Text(
              'Exclusivo',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppPalette.purple700,
              ),
            ),
          ),
        ),
        if (onPressUnlock != null)
          GestureDetector(
            onTap: onPressUnlock,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppPalette.purple100,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                child: Text(
                  'Desbloquear @$memberName',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.purple700,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
