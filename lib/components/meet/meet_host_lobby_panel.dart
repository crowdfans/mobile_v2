import 'package:crowdfans/components/meet/meet_shared.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/meet_event.dart';
import 'package:flutter/material.dart';

/// Lobby do host: countdown, fila e gate `Iniciar Atendimento`.
class MeetHostLobbyPanel extends StatelessWidget {
  const MeetHostLobbyPanel({
    super.key,
    required this.snapshot,
    required this.busy,
    required this.onStartServing,
    required this.onFinish,
  });

  final MeetEventSnapshot snapshot;
  final bool busy;
  final VoidCallback onStartServing;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final remaining = snapshot.lobbyRemainingSeconds;
    final canStart = snapshot.canStartServing && !busy;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Lobby aberto',
          style: TextStyle(fontSize: 14, color: colors.textSecondary),
        ),
        const SizedBox(height: 8),
        Text(
          formatMeetCountdown(remaining),
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w700,
            fontFamily: 'SpaceMono',
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${snapshot.queueCount} na fila · gate: fila ≥ 10 ou timer zerado',
          style: TextStyle(fontSize: 15, color: colors.textSecondary),
        ),
        const SizedBox(height: 28),
        FilledButton(
          onPressed: canStart ? onStartServing : null,
          style: FilledButton.styleFrom(
            backgroundColor: AppPalette.green500,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppPalette.green500.withValues(alpha: 0.35),
            minimumSize: const Size.fromHeight(52),
          ),
          child: Text(busy ? 'Aguarde…' : 'Iniciar Atendimento'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: busy ? null : onFinish,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppPalette.red500,
            side: const BorderSide(color: AppPalette.red500),
            minimumSize: const Size.fromHeight(48),
          ),
          child: const Text('Encerrar Meet & Greet'),
        ),
      ],
    );
  }
}
