import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/wallet_service.dart';
import 'package:flutter/material.dart';

/// Pacote de Jam Coins com ação de compra.
class WalletPackCard extends StatelessWidget {
  const WalletPackCard({
    super.key,
    required this.pack,
    required this.busy,
    required this.onBuy,
  });

  final JamCoinPack pack;
  final bool busy;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final price = (pack.priceCents / 100).toStringAsFixed(2);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pack.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                    ),
                  ),
                  Text(
                    '${pack.coins} moedas · R\$ $price',
                    style: TextStyle(fontSize: 12, color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            FilledButton(
              onPressed: busy ? null : onBuy,
              child: Text(busy ? '...' : 'Comprar'),
            ),
          ],
        ),
      ),
    );
  }
}
