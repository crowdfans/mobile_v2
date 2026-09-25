import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Etapa numerada do fluxo PIX (CF-171).
///
/// Referência: numeração grande e em negrito à esquerda, sem chip/caixa.
class WalletPixStepRow extends StatelessWidget {
  const WalletPixStepRow({
    super.key,
    required this.number,
    required this.text,
    this.child,
  });

  final String number;
  final String text;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 40,
          child: Text(
            number,
            style: TextStyle(
              fontSize: 26,
              height: 1.1,
              fontWeight: FontWeight.w900,
              color: colors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  height: 20 / 14,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              if (child != null) ...[
                const SizedBox(height: 8),
                child!,
              ],
            ],
          ),
        ),
      ],
    );
  }
}
