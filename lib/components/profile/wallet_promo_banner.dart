import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Banner promocional de recarga com countdown.
class WalletPromoBanner extends StatelessWidget {
  const WalletPromoBanner({
    super.key,
    required this.countdown,
    required this.onRecharge,
  });

  final String countdown;
  final VoidCallback onRecharge;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.primaryStrong,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Oferta termina em $countdown',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colors.buttonPrimaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '15% OFF na recarga',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: colors.buttonPrimaryText,
              ),
            ),
            const SizedBox(height: 12),
            Material(
              color: colors.background,
              borderRadius: BorderRadius.circular(999),
              child: InkWell(
                onTap: onRecharge,
                borderRadius: BorderRadius.circular(999),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  child: Text(
                    'Recarregar agora',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: colors.primaryStrong,
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
