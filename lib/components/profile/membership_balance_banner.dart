import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Saldo de Jam Coins no topo da tela de memberships.
class MembershipBalanceBanner extends StatelessWidget {
  const MembershipBalanceBanner({super.key, required this.balance});

  final String balance;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.toll, size: 30, color: colors.primaryStrong),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Saldo da carteira',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$balance Jam Coins',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
