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

  /// Formata quantidade no padrão BR (ex.: 1.300).
  String coinsLabel() {
    final raw = pack.coins.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      final fromEnd = raw.length - i;
      if (i > 0 && fromEnd % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(raw[i]);
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    // Referência: fundo lilás + borda lilás fina quando selecionado.
    return Material(
      color: selected ? const Color(0xFFF3EEFF) : colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: selected ? const Color(0xFFD6C7FF) : colors.border,
          width: selected ? 1.2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                      coinsLabel(),
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
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (featured)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3EEFF),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Mais pedido',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: colors.primary,
                          ),
                        ),
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
                ],
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
