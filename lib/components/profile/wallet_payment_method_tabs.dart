import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

enum WalletPaymentMethod { pix, debit, credit }

/// Abas PIX / Débito / Crédito.
class WalletPaymentMethodTabs extends StatelessWidget {
  const WalletPaymentMethodTabs({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final WalletPaymentMethod selected;
  final ValueChanged<WalletPaymentMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    Widget tab(String label, WalletPaymentMethod method) {
      final active = selected == method;
      return Expanded(
        child: InkWell(
          onTap: () => onChanged(method),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                    color: active ? colors.textPrimary : colors.textSecondary,
                  ),
                ),
              ),
              Container(
                height: 3,
                color: active ? colors.textPrimary : Colors.transparent,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Text(
          'Meio de pagamento',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            tab('PIX', WalletPaymentMethod.pix),
            tab('Débito', WalletPaymentMethod.debit),
            tab('Crédito', WalletPaymentMethod.credit),
          ],
        ),
        Divider(height: 1, color: colors.border),
      ],
    );
  }
}
