import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Card de saldo na home de Jam Coins.
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
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.toll, size: 36, color: colors.primaryStrong),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Seu saldo',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colors.textSecondary,
                    ),
                  ),
                  Text(
                    balance,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
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
                    horizontal: 14,
                    vertical: 8,
                  ),
                  child: Text(
                    'Recarregar',
                    style: TextStyle(
                      fontSize: 13,
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
