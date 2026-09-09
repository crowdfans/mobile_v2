import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Aviso quando o modo silencioso está ligado.
class NotificationQuietModeNote extends StatelessWidget {
  const NotificationQuietModeNote({super.key, this.message});

  final String? message;

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
          message ?? 'O modo silencioso mantém apenas convites, lembretes, renovações e alertas financeiros críticos.',
          style: TextStyle(
            fontSize: 12,
            height: 1.5,
            color: colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
