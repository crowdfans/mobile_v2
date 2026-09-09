import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/utils/password_util.dart';
import 'package:flutter/material.dart';

/// Barra e requisitos da senha no cadastro.
class PasswordStrengthMeter extends StatelessWidget {
  const PasswordStrengthMeter({super.key, required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final checks = getPasswordChecks(password);
    final score = checks.where((check) => check.ok).length;
    final filled = score == 0 ? 1 : score;
    final color = passwordStrengthColor(score);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Força da senha',
              style: TextStyle(fontSize: 13, color: colors.textPrimary),
            ),
            const Spacer(),
            Text(
              passwordStrengthLabel(score),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (var i = 0; i < 4; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: i < filled ? color : colors.surfaceAlt,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const SizedBox(height: 6),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        for (final check in checks)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '${check.ok ? 'OK' : 'Falta'} - ${check.label}',
              style: TextStyle(
                fontSize: 12,
                color: check.ok ? colors.success : colors.textTertiary,
              ),
            ),
          ),
        if (!isStrongPassword(password))
          Text(
            'Sua senha ainda não atende todos os requisitos.',
            style: TextStyle(fontSize: 12, color: colors.danger),
          ),
      ],
    );
  }
}
