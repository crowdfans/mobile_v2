import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Card de strike, expulsão ou apelação na tela de moderação.
class FanClubModerationCard extends StatelessWidget {
  const FanClubModerationCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.body,
    this.onApprove,
    this.onReject,
  });

  final String title;
  final String subtitle;
  final String? body;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

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
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: colors.textTertiary),
              ),
            ],
            if ((body ?? '').isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                body!,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: colors.textSecondary,
                ),
              ),
            ],
            if (onApprove != null || onReject != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (onApprove != null)
                    TextButton(
                      onPressed: onApprove,
                      child: const Text('Aprovar retorno'),
                    ),
                  if (onReject != null)
                    TextButton(
                      onPressed: onReject,
                      child: Text(
                        'Rejeitar',
                        style: TextStyle(color: colors.danger),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
