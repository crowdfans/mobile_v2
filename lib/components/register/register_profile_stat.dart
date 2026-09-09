import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Estatística de exemplo no preview do perfil.
class RegisterProfileStat extends StatelessWidget {
  const RegisterProfileStat({
    super.key,
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 13, color: colors.textSecondary),
        ),
      ],
    );
  }
}
