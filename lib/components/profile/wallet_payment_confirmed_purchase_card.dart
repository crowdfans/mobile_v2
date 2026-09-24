import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Card "Detalhes da compra" com total real da recarga (CF-204).
class WalletPaymentConfirmedPurchaseCard extends StatelessWidget {
  const WalletPaymentConfirmedPurchaseCard({
    super.key,
    required this.coinsTotal,
    this.baseCoins,
    this.bonusCoins,
    this.checkoutId,
  });

  final int coinsTotal;
  final int? baseCoins;
  final int? bonusCoins;
  final String? checkoutId;

  String? get breakdownLabel {
    final base = baseCoins;
    final bonus = bonusCoins;
    if (base == null || bonus == null || bonus <= 0) {
      return null;
    }
    return '$base JC + $bonus bônus';
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final breakdown = breakdownLabel;
    final id = checkoutId?.trim() ?? '';
    return Semantics(
      label: [
        'Recarga concluída',
        'Detalhes da compra: $coinsTotal Jam Coins',
        if (breakdown != null) breakdown,
        if (id.isNotEmpty) 'Identificador $id',
      ].join('. '),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Column(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppPalette.purple50,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Image.asset(
                        'assets/images/jam-coin.png',
                        width: 36,
                        height: 36,
                        excludeFromSemantics: true,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.monetization_on,
                          size: 36,
                          color: Color(0xFFF5C451),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Recarga concluída',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detalhes da compra',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/jam-coin.png',
                          width: 22,
                          height: 22,
                          excludeFromSemantics: true,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.monetization_on,
                            size: 22,
                            color: Color(0xFFF5C451),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$coinsTotal',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    if (breakdown != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        breakdown,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
