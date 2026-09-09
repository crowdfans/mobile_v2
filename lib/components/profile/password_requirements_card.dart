import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Critérios visuais da nova senha na tela de segurança.
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
    final checks = [
      (ok: password.length >= 8, label: 'Pelo menos 8 caracteres'),
      (ok: RegExp(r'[A-Z]').hasMatch(password), label: 'Uma letra maiúscula'),
      (ok: RegExp(r'[a-z]').hasMatch(password), label: 'Uma letra minúscula'),
      (ok: RegExp(r'\d').hasMatch(password), label: 'Um número'),
      (
        ok: RegExp(r'[^A-Za-z0-9]').hasMatch(password),
        label: 'Um símbolo (recomendado)',
      ),
      (
        ok: password.isNotEmpty && password == confirmPassword,
        label: 'Confirmação igual',
      ),
    ];
    final score = [
      password.length >= 8,
      RegExp(r'[A-Z]').hasMatch(password),
      RegExp(r'[a-z]').hasMatch(password),
      RegExp(r'\d').hasMatch(password),
      RegExp(r'[^A-Za-z0-9]').hasMatch(password),
    ].where((ok) => ok).length;
    final strength = password.isEmpty
        ? (label: '', color: colors.border)
        : score <= 2
        ? (label: 'Fraca', color: colors.danger)
        : score <= 4
        ? (label: 'Média', color: const Color(0xFFD4A017))
        : (label: 'Forte', color: AppPalette.green700);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Critérios da nova senha',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                if (strength.label.isNotEmpty)
                  Text(
                    strength.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: strength.color,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: score / 5,
                minHeight: 6,
                backgroundColor: colors.surfaceAlt,
                color: strength.color,
              ),
            ),
            const SizedBox(height: 8),
            for (final item in checks)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: item.ok ? AppPalette.green700 : colors.border,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 12,
                        color: item.ok
                            ? colors.textPrimary
                            : colors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
