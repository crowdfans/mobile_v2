import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Aviso amarelo de strike / moderação acima do feed do fã-clube.
class FanClubModerationWarningBanner extends StatelessWidget {
  const FanClubModerationWarningBanner({
    super.key,
    required this.reason,
    required this.remainingChances,
  });

  final String reason;
  final int remainingChances;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final chances = remainingChances < 0 ? 0 : remainingChances;
    return Semantics(
      liveRegion: true,
      label:
          'Aviso de moderação. $reason. $chances chances restantes.',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFFFF4D6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF5C84C)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFB45309),
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Você recebeu um aviso neste fã clube',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reason.trim().isEmpty
                          ? 'Você recebeu um aviso da moderação deste fã clube.'
                          : reason.trim(),
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      chances == 1
                          ? 'Você ainda tem 1 chance para ajustar seu comportamento.'
                          : 'Você ainda tem $chances chances para ajustar seu comportamento.',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
