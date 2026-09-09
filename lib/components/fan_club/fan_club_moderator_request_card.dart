import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/fan_club_service.dart';
import 'package:flutter/material.dart';

/// Pedido pendente de moderação.
class FanClubModeratorRequestCard extends StatelessWidget {
  const FanClubModeratorRequestCard({
    super.key,
    required this.request,
    required this.onApprove,
    required this.onReject,
  });

  final FanClubModeratorRequest request;
  final VoidCallback onApprove;
  final VoidCallback onReject;

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
              request.displayName,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            if (request.handle.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                request.handle,
                style: TextStyle(fontSize: 12, color: colors.textTertiary),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              request.reason,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton(onPressed: onApprove, child: const Text('Aprovar')),
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
        ),
      ),
    );
  }
}
