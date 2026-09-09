import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Card de lista nas telas de ocultos / memórias / bloqueados.
class SettingsRestoreRow extends StatelessWidget {
  const SettingsRestoreRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.busy,
    required this.onRestore,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final bool busy;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
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
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                subtitle,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: colors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 10),
            if (busy)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              TextButton(
                onPressed: onRestore,
                style: TextButton.styleFrom(
                  backgroundColor: colors.surfaceAlt,
                  foregroundColor: colors.textPrimary,
                ),
                child: Text(
                  actionLabel,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
