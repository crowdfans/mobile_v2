import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/wallet_service.dart';
import 'package:crowdfans/utils/wallet_user_message.dart';
import 'package:flutter/material.dart';

/// Recibo PIX após checkout (sem texto técnico ao usuário).
class WalletPixReceipt extends StatelessWidget {
  const WalletPixReceipt({
    super.key,
    required this.receipt,
    required this.onCopyPix,
  });

  final WalletCheckoutResult receipt;
  final VoidCallback onCopyPix;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final pix = receipt.pixCopyPaste?.trim() ?? '';
    final userMessage = walletUserFacingMessage(receipt.message);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              receipt.status == 'paid' ? 'Pago' : 'Aguardando PIX',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
              ),
            ),
            if (pix.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                pix,
                style: TextStyle(fontSize: 12, color: colors.textSecondary),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: onCopyPix,
                child: const Text('Copiar PIX'),
              ),
            ],
            if (userMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                userMessage,
                style: TextStyle(fontSize: 12, color: colors.textSecondary),
              ),
            ] else if (receipt.message == null ||
                receipt.message!.trim().isEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '${receipt.coins} moedas · ${receipt.provider}',
                style: TextStyle(fontSize: 12, color: colors.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
