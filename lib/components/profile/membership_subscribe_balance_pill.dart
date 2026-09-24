import 'package:flutter/material.dart';

/// Pill de saldo Jam Coins no header de Assinar (CF-206).
class MembershipSubscribeBalancePill extends StatelessWidget {
  const MembershipSubscribeBalancePill({
    super.key,
    required this.balance,
    this.onPressed,
  });

  final String balance;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF5C451),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/jam-coin.png',
                width: 16,
                height: 16,
                excludeFromSemantics: true,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.monetization_on,
                  size: 16,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                balance,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1C1C1E),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
