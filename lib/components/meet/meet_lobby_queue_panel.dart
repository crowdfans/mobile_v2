import 'package:crowdfans/components/meet/meet_shared.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/meet_event.dart';
import 'package:flutter/material.dart';

/// Painel do lobby com countdown, fila e CTA join/leave.
class MeetLobbyQueuePanel extends StatelessWidget {
  const MeetLobbyQueuePanel({
    super.key,
    required this.snapshot,
    required this.busy,
    required this.onJoinQueue,
    required this.onLeaveQueue,
  });

  final MeetEventSnapshot snapshot;
  final bool busy;
  final VoidCallback onJoinQueue;
  final VoidCallback onLeaveQueue;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final remaining = snapshot.lobbyRemainingSeconds;
    final statusLabel = snapshot.isServing
        ? 'Atendimento em andamento'
        : 'Lobby aberto';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          statusLabel,
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
          snapshot.isServing
              ? 'Fila ativa · ${snapshot.queueCount} na fila'
              : 'Countdown do lobby · ${snapshot.queueCount} na fila',
          style: TextStyle(fontSize: 15, color: colors.textSecondary),
        ),
        if (snapshot.inQueue && snapshot.queuePosition != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppPalette.green500.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Você está na posição ${snapshot.queuePosition}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
          ),
        ],
        const SizedBox(height: 28),
        if (snapshot.inQueue)
          OutlinedButton(
            onPressed: busy ? null : onLeaveQueue,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppPalette.red500,
              side: const BorderSide(color: AppPalette.red500),
              minimumSize: const Size.fromHeight(52),
            ),
            child: Text(busy ? 'Aguarde…' : 'Sair da fila'),
          )
        else
          FilledButton(
            onPressed: busy || snapshot.isFinished ? null : onJoinQueue,
            style: FilledButton.styleFrom(
              backgroundColor: AppPalette.green500,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(52),
            ),
            child: Text(busy ? 'Aguarde…' : 'Entrar na fila'),
          ),
      ],
    );
  }
}
