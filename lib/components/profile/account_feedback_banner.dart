import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Mensagem de erro ou sucesso no formulário de conta.
class AccountFeedbackBanner extends StatelessWidget {
  const AccountFeedbackBanner({
    super.key,
    required this.message,
    required this.success,
  });

  final String message;
  final bool success;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          message,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            height: 1.4,
            color: success ? AppPalette.green700 : colors.danger,
          ),
        ),
      ),
    );
  }
}
