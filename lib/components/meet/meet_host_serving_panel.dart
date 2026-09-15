import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/meet_event.dart';
import 'package:flutter/material.dart';

/// Painel serving: call_next manual, report pendente e finish.
class MeetHostServingPanel extends StatelessWidget {
  const MeetHostServingPanel({
    super.key,
    required this.snapshot,
    required this.busy,
    required this.onCallNext,
    required this.onFinish,
    required this.onOpenReport,
  });

  final MeetEventSnapshot snapshot;
  final bool busy;
  final VoidCallback onCallNext;
  final VoidCallback onFinish;
  final VoidCallback onOpenReport;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final blocked = snapshot.pendingEarlyEndReport;
    final canCall = !busy && !blocked && snapshot.queueCount > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Atendimento em andamento',
          style: TextStyle(fontSize: 14, color: colors.textSecondary),
        ),
        const SizedBox(height: 8),
        Text(
          '${snapshot.queueCount} na fila',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        if (blocked) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppPalette.red500.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Report de early-end obrigatório antes do próximo.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: busy ? null : onOpenReport,
                  child: const Text('Abrir Report'),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 28),
        FilledButton(
          onPressed: canCall ? onCallNext : null,
          style: FilledButton.styleFrom(
            backgroundColor: AppPalette.green500,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppPalette.green500.withValues(alpha: 0.35),
            minimumSize: const Size.fromHeight(52),
          ),
          child: Text(busy ? 'Aguarde…' : 'Chamar próximo'),
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
