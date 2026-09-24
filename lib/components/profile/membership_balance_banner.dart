import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Saldo compacto no topo de Meus Memberships (CF-167).
class MembershipBalanceBanner extends StatelessWidget {
  const MembershipBalanceBanner({super.key, required this.balance});

  final String balance;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
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
          const SizedBox(width: 8),
          Text(
            '$balance Jam Coins',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
