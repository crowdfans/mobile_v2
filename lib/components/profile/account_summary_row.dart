import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Linha de resumo do hub “Seu Perfil” (rótulo à esquerda, valor à direita).
class AccountSummaryRow extends StatelessWidget {
  const AccountSummaryRow({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
