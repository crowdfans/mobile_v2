import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Instruções e código PIX após o checkout sandbox.
class WalletPixCodePanel extends StatelessWidget {
  const WalletPixCodePanel({
    super.key,
    required this.pixCode,
    required this.onCopy,
  });

  final String pixCode;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '01 Copie o código Pix:',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.primary.withValues(alpha: 0.45)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    pixCode,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onCopy,
                  icon: Icon(Icons.copy, color: colors.primary),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '02 Abra o aplicativo do seu banco, selecione “Pix” e depois “Pix copia e cola”.',
          style: TextStyle(
            fontSize: 14,
            height: 20 / 14,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '03 Cole o código, confira se as informações estão corretas e confirme o pagamento.',
          style: TextStyle(
            fontSize: 14,
            height: 20 / 14,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }
}
