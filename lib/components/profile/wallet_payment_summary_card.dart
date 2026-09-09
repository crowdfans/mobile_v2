import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Resumo do pacote na tela de pagamento.
class WalletPaymentSummaryCard extends StatelessWidget {
  const WalletPaymentSummaryCard({
    super.key,
    required this.coinsLabel,
    required this.detail,
    required this.priceLabel,
  });

  final String coinsLabel;
  final String detail;
  final String priceLabel;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.toll, size: 32, color: colors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coinsLabel,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: colors.textPrimary,
                    ),
                  ),
                  Text(
                    detail,
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              priceLabel,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: colors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
