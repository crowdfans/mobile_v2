import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/wallet_service.dart';
import 'package:flutter/material.dart';

/// Tile selecionável de pacote na tela de recarga (CF-169).
class WalletRechargePackTile extends StatelessWidget {
  const WalletRechargePackTile({
    super.key,
    required this.pack,
    required this.selected,
    required this.onPressed,
    this.featured = false,
  });

  final JamCoinPack pack;
  final bool selected;
  final bool featured;
  final VoidCallback onPressed;

  String priceLabel() {
    final reais =
        (pack.priceCents / 100).toStringAsFixed(2).replaceAll('.', ',');
    return 'R\$ $reais';
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Material(
      color: selected ? colors.primary.withValues(alpha: 0.08) : colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? colors.primary : colors.border,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Image.asset(
                'assets/images/jam-coin.png',
                width: 36,
                height: 36,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.monetization_on,
                  size: 36,
                  color: Color(0xFFF5C451),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pack.coins.toString(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      pack.label,
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.textSecondary,
                      ),
                    ),
                    if (featured) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Mais pedido',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                priceLabel(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: selected ? colors.primary : colors.textTertiary,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
