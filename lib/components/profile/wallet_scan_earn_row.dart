import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Linha "Escaneie e ganhe" → referral (CF-168).
class WalletScanEarnRow extends StatelessWidget {
  const WalletScanEarnRow({
    super.key,
    required this.onPressed,
    this.bonusLabel = '+120',
  });

  final VoidCallback onPressed;
  final String bonusLabel;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Escaneie e ganhe',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              Image.asset(
                'assets/images/jam-coin.png',
                width: 22,
                height: 22,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.monetization_on,
                  size: 22,
                  color: Color(0xFFF5C451),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                bonusLabel,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
