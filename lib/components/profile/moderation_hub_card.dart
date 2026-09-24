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
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

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
