import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Bloco de candidatura à moderação no “Ver mais” (hierarquia distinta da lista).
class FanClubModerationCandidacySection extends StatelessWidget {
  const FanClubModerationCandidacySection({
    super.key,
    required this.onRequestPressed,
  });

  final VoidCallback onRequestPressed;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Quero ajudar como moderador(a)',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Se você quiser participar da moderação desse fã-clube, envie uma '
          'solicitação para o artista contando por que faria sentido assumir '
          'esse papel.',
          style: TextStyle(
            fontSize: 14,
            height: 1.45,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton(
            onPressed: onRequestPressed,
            style: FilledButton.styleFrom(
              backgroundColor: colors.surfaceAlt,
              foregroundColor: colors.textPrimary,
              elevation: 0,
              shape: const StadiumBorder(),
            ),
            child: const Text(
              'Solicitar moderação',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
