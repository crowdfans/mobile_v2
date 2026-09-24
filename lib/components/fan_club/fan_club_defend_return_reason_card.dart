import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Card rosado com o motivo da expulsão (CF-200).
class FanClubDefendReturnReasonCard extends StatelessWidget {
  const FanClubDefendReturnReasonCard({super.key, required this.reason});

  final String reason;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final text = reason.trim().isEmpty
        ? 'A moderação removeu seu acesso a esta comunidade.'
        : reason.trim();
    return Semantics(
      label: 'Motivo da expulsão: $text',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFFFE8E8),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.danger.withValues(alpha: 0.35)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Motivo da expulsão',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: colors.danger,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  height: 20 / 14,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
