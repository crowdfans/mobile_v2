import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Pill compacto de saldo no cabeçalho de Meus Memberships (CF-167).
///
/// Só o número + moeda dourada — sem cartão “Saldo da carteira” nem CTAs
/// de recarga (esses ficam na carteira / CF-168).
class MembershipBalancePill extends StatelessWidget {
  const MembershipBalancePill({super.key, required this.balance});

  final String balance;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/jam-coin.png',
            width: 18,
            height: 18,
            errorBuilder: (_, _, _) => const Icon(
              Icons.monetization_on,
              size: 18,
              color: Color(0xFFF5C451),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            balance,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
