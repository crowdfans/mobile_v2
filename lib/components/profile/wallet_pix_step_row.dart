import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Etapa numerada do fluxo PIX (CF-171).
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
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.surfaceAlt,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            number,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 12),
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
