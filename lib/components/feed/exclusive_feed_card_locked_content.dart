import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Conteúdo substituto do post exclusivo quando o viewer não tem membership.
class ExclusiveFeedCardLockedContent extends StatelessWidget {
  const ExclusiveFeedCardLockedContent({
    super.key,
    required this.resolvedUsername,
    required this.canUnlock,
    required this.onPressUnlock,
    this.unlockLabel = 'Assinar Membership',
  });

  final String resolvedUsername;
  final bool canUnlock;
  final VoidCallback onPressUnlock;
  final String unlockLabel;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final badgeBg = isDark ? AppPalette.purple950 : AppPalette.purple50;
    final badgeFg = isDark ? AppPalette.purple300 : AppPalette.purple600;
    final badgeText = isDark ? AppPalette.purple100 : AppPalette.purple700;
    final buttonBorder = isDark ? AppPalette.purple800 : AppPalette.purple200;
    final buttonFg = isDark ? AppPalette.purple100 : AppPalette.purple700;

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/icons/Media & devices/music-note-01.svg',
                    width: 14,
                    height: 14,
                    colorFilter: ColorFilter.mode(badgeFg, BlendMode.srcIn),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Exclusivo',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: badgeText,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Conteúdo para membros',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Assine o membership de $resolvedUsername para liberar posts exclusivos.',
            style: TextStyle(
              fontSize: 14,
              height: 20 / 14,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 42,
            child: OutlinedButton(
              onPressed: canUnlock ? onPressUnlock : null,
              style: OutlinedButton.styleFrom(
                backgroundColor: colors.surface,
                foregroundColor: buttonFg,
                side: BorderSide(color: buttonBorder),
                shape: const StadiumBorder(),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    unlockLabel,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: buttonFg,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SvgPicture.asset(
                    'assets/icons/General/plus.svg',
                    width: 14,
                    height: 14,
                    colorFilter: ColorFilter.mode(buttonFg, BlendMode.srcIn),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
