import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Nota de saldo atualizado após confirmação da recarga (CF-204).
class WalletPaymentConfirmedInfoNote extends StatelessWidget {
  const WalletPaymentConfirmedInfoNote({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Text(
          'A transação foi concluída com sucesso e o saldo já foi atualizado na sua conta.',
          style: TextStyle(
            fontSize: 13,
            height: 18 / 13,
            color: colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
