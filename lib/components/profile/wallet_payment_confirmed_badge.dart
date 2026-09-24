import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Badge verde "Pagamento confirmado" (print CF-204).
class WalletPaymentConfirmedBadge extends StatelessWidget {
  const WalletPaymentConfirmedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Pagamento confirmado',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppPalette.green50,
          borderRadius: BorderRadius.circular(999),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            'Pagamento confirmado',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppPalette.green700,
            ),
          ),
        ),
      ),
    );
  }
}
