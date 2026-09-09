import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Título + subtítulo das etapas de cadastro (espelho do Expo).
class RegisterStepHeader extends StatelessWidget {
  const RegisterStepHeader({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Column(
      children: [
        const SizedBox(height: 32),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            height: 34 / 28,
            fontWeight: FontWeight.w800,
            color: colors.textPrimary,
          ),
        ),
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              height: 22 / 16,
              color: colors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
