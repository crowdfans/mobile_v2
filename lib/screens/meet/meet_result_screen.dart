import 'package:crowdfans/components/meet/meet_shared.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Feedback pós-chamada (sucesso / missed / declined / cancelled).
class MeetResultScreen extends StatelessWidget {
  const MeetResultScreen({
    super.key,
    required this.status,
    this.reason = '',
    this.peerName = '',
  });

  final String status;
  final String reason;
  final String peerName;

  String get _title {
    switch (status) {
      case 'ended':
        return reason == 'timeout' ? 'Tempo esgotado' : 'Chamada encerrada';
      case 'declined':
        return 'Chamada recusada';
      case 'missed':
        return 'Chamada perdida';
      case 'cancelled':
        return 'Chamada cancelada';
      default:
        return 'Meet & Greet';
    }
  }

  String get _subtitle {
    final peer = peerName.trim();
    switch (status) {
      case 'ended':
        return peer.isEmpty
            ? 'Obrigado pelo Meet & Greet de 60 segundos.'
            : 'Meet com $peer concluído.';
      case 'declined':
        return peer.isEmpty
            ? 'A outra pessoa recusou a chamada.'
            : '$peer recusou a chamada.';
      case 'missed':
        return 'Ninguém atendeu a tempo.';
      case 'cancelled':
        return 'A solicitação foi cancelada.';
      default:
        return '';
    }
  }

  IconData get _icon {
    switch (status) {
      case 'ended':
        return Icons.check_circle_outline;
      case 'declined':
      case 'cancelled':
        return Icons.call_end;
      case 'missed':
        return Icons.phone_missed;
      default:
        return Icons.videocam_off_outlined;
    }
  }

  void handleDone(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(Pages.home);
  }

  @override
  Widget build(BuildContext context) {
    return MeetScreenFrame(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const Spacer(),
            Icon(_icon, size: 72, color: AppPalette.green400),
            const SizedBox(height: 20),
            Text(
              _title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: () => handleDone(context),
                style: FilledButton.styleFrom(
                  backgroundColor: AppPalette.purple500,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Voltar'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
