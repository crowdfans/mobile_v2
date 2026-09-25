import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Pill de saldo Jam Coins no header de Assinar (CF-206).
/// Print: fundo branco, borda fina, ícone de moeda + saldo.
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
    final colors = CrowdFansTheme.of(context);
    return Material(
      color: colors.surface,
      shape: StadiumBorder(side: BorderSide(color: colors.border)),
      child: InkWell(
        onTap: onPressed,
        customBorder: const StadiumBorder(),
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
                  color: Color(0xFFF5C451),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                balance,
                style: TextStyle(
                  fontSize: 13,
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
