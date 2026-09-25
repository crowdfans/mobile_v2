import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Pill de saldo Jam Coins no cabeçalho (CF-167).
class MembershipBalancePill extends StatelessWidget {
  const MembershipBalancePill({super.key, required this.balance});

  final String balance;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/jam-coin.png',
            width: 16,
            height: 16,
            errorBuilder: (_, _, _) => const Icon(
              Icons.monetization_on,
              size: 16,
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
