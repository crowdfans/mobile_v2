import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Paywall do lobby quando o fã não tem membership.
class MeetLobbyMembershipPaywall extends StatelessWidget {
  const MeetLobbyMembershipPaywall({
    super.key,
    required this.artistName,
    required this.onSubscribe,
  });

  final String artistName;
  final VoidCallback onSubscribe;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final name = artistName.trim().isEmpty ? 'este artista' : artistName.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Membership necessária',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Para entrar no Meet & Greet de $name, assine a membership e volte ao lobby.',
          style: TextStyle(fontSize: 15, color: colors.textSecondary, height: 1.4),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: onSubscribe,
          style: FilledButton.styleFrom(
            backgroundColor: AppPalette.green500,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
          ),
          child: const Text('Assinar membership'),
        ),
      ],
    );
  }
}
