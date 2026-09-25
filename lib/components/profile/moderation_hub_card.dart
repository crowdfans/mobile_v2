import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Opção do hub Fã Clube (sem contorno — CF-163).
class ModerationHubCard extends StatelessWidget {
  const ModerationHubCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badgeCount,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;
  /// Contagem real à direita (print CF-163); null = chevron.
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      height: 18 / 13,
                      color: colors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (badgeCount != null)
              Container(
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.surfaceAlt,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$badgeCount',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colors.textSecondary,
                  ),
                ),
              )
            else
              SvgPicture.asset(
                'assets/icons/arrows/chevron-right.svg',
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(
                  colors.textTertiary,
                  BlendMode.srcIn,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
