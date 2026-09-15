import 'package:crowdfans/components/meet/meet_shared.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Overlay da call do fã: timer + status, **sem** Hang Up.
class MeetEventCallChrome extends StatelessWidget {
  const MeetEventCallChrome({
    super.key,
    required this.peerName,
    required this.remainingSeconds,
    required this.joining,
    this.statusMessage,
    this.error,
  });

  final String peerName;
  final int remainingSeconds;
  final bool joining;
  final String? statusMessage;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final remaining = remainingSeconds < 0 ? 0 : remainingSeconds;
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: remaining <= 10
                  ? AppPalette.red500.withValues(alpha: 0.9)
                  : Colors.black54,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              formatMeetCountdown(remaining),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                fontFamily: 'SpaceMono',
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            peerName.trim().isEmpty ? 'Meet & Greet' : peerName.trim(),
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          if (joining) ...[
            const SizedBox(height: 16),
            const CircularProgressIndicator(color: Colors.white),
          ],
          if (statusMessage != null) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                statusMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
          ],
          if (error != null) ...[
            const SizedBox(height: 8),
            Text(
              error!,
              style: const TextStyle(color: AppPalette.red300),
            ),
          ],
          const Spacer(),
          const Padding(
            padding: EdgeInsets.only(bottom: 28),
            child: Text(
              'A chamada encerra automaticamente em 90 segundos.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
