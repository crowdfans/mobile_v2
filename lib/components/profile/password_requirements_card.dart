import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Critérios da nova senha — apresentação da referência CF-164 (sem caixa).
class PasswordRequirementsCard extends StatelessWidget {
  const PasswordRequirementsCard({
    super.key,
    required this.password,
    required this.confirmPassword,
  });

  final String password;
  final String confirmPassword;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    // Ordem e rótulos do print YouTrack (CF-164). Validação real permanece no form.
    final checks = [
      (ok: password.length >= 8, label: 'Pelo menos 8 caracteres'),
      (
        ok: RegExp(r'[A-Z]').hasMatch(password),
        label: 'Pelo menos 1 letra maiúscula',
      ),
      (ok: RegExp(r'\d').hasMatch(password), label: 'Pelo menos 1 número'),
      (
        ok: password.isNotEmpty && password == confirmPassword,
        label: 'Confirmação igual à nova senha',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Critérios da nova senha',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        for (final item in checks)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              '·  ${item.label}',
              style: TextStyle(
                fontSize: 14,
                height: 1.35,
                color: item.ok ? colors.textPrimary : colors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }
}
