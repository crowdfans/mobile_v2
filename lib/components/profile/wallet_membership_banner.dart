import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// CTA de membership na home de Jam Coins.
class WalletMembershipBanner extends StatelessWidget {
  const WalletMembershipBanner({super.key, required this.onSubscribe});

  final VoidCallback onSubscribe;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MEMBERSHIP FAN',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Assine e desbloqueie conteúdo exclusivo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Material(
              color: colors.buttonPrimary,
              borderRadius: BorderRadius.circular(999),
              child: InkWell(
                onTap: onSubscribe,
                borderRadius: BorderRadius.circular(999),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  child: Text(
                    'Assinar agora mesmo',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: colors.buttonPrimaryText,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
