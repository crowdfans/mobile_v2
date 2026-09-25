import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Card de saldo na home de Jam Coins (CF-168).
class WalletHomeBalanceCard extends StatelessWidget {
  const WalletHomeBalanceCard({
    super.key,
    required this.balance,
    required this.onRecharge,
  });

  final String balance;
  final VoidCallback onRecharge;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/jam-coin.png',
              width: 44,
              height: 44,
              errorBuilder: (_, _, _) => const Icon(
                Icons.monetization_on,
                size: 44,
                color: Color(0xFFF5C451),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jam Coins',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    balance,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Material(
              color: colors.textPrimary,
              borderRadius: BorderRadius.circular(999),
              child: InkWell(
                onTap: onRecharge,
                borderRadius: BorderRadius.circular(999),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Text(
                    'Recarregar',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: colors.background,
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
