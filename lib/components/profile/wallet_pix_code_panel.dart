import 'package:crowdfans/components/profile/wallet_pix_step_row.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Instruções e código PIX após o checkout (CF-171).
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
        WalletPixStepRow(
          number: '01',
          text: 'Copie o código Pix:',
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colors.primary.withValues(alpha: 0.35),
              ),
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
        ),
        const SizedBox(height: 16),
        const WalletPixStepRow(
          number: '02',
          text:
              'Abra o aplicativo do seu banco, selecione “Pix” e depois “Pix copia e cola”.',
        ),
        const SizedBox(height: 16),
        const WalletPixStepRow(
          number: '03',
          text:
              'Cole o código, confira se as informações estão corretas e confirme o pagamento.',
        ),
      ],
    );
  }
}
