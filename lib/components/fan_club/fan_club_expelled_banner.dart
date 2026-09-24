import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Aviso vermelho de expulsão com motivo e CTA para defender o retorno.
class FanClubExpelledBanner extends StatelessWidget {
  const FanClubExpelledBanner({
    super.key,
    required this.reason,
    required this.onDefend,
  });

  final String reason;
  final VoidCallback onDefend;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Semantics(
      liveRegion: true,
      label: 'Você foi expulso. Motivo: $reason',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFFFE8E8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.danger.withValues(alpha: 0.45)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.block, color: colors.danger, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Você foi expulso deste fã-clube',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          reason.trim().isEmpty
                              ? 'A moderação removeu seu acesso a esta comunidade.'
                              : reason.trim(),
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: onDefend,
                  style: TextButton.styleFrom(
                    backgroundColor: colors.danger,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  child: const Text(
                    'Defender por que voltar',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
