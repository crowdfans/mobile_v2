import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Aviso vermelho de expulsão com motivo e CTA para defender o retorno (CF-229).
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
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Você foi expulso deste fã clube',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: colors.danger,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                reason.trim().isEmpty
                    ? 'A moderação removeu seu acesso a esta comunidade.'
                    : reason.trim(),
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              AppButton(
                label: 'Defender por que voltar',
                variant: AppButtonVariant.dark,
                onPressed: onDefend,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
