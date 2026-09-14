import 'dart:async';

import 'package:crowdfans/components/meet/meet_shared.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/video_call.dart';
import 'package:crowdfans/services/comet_chat_call_service.dart';
import 'package:crowdfans/services/video_call_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

/// Chamada ativa — timer backend + CometChat (ou sandbox).
class MeetCallScreen extends StatefulWidget {
  const MeetCallScreen({super.key, required this.callId});

  final String callId;

  @override
  State<MeetCallScreen> createState() => _MeetCallScreenState();
}

class _MeetCallScreenState extends State<MeetCallScreen> {
  VideoCall? _call;
  Widget? _cometWidget;
  String? _statusMessage;
  String? _error;
  var _ending = false;
  var _joining = true;
  VoidCallback? _unsubscribe;

  @override
  void initState() {
    super.initState();
    handleBootstrap();
  }

  @override
  void dispose() {
    _unsubscribe?.call();
    unawaited(CometChatCallService.leave());
    super.dispose();
  }

  Future<void> handleBootstrap() async {
    try {
      await [
        Permission.camera,
        Permission.microphone,
      ].request();

      final call = await VideoCallService.get(widget.callId);
      if (!mounted) {
        return;
      }
      setState(() => _call = call);
      if (call.isTerminal) {
        context.pushReplacement(
          Pages.meetResultOf(
            status: call.status,
            reason: call.endedReason,
            peerName: call.fanName.isNotEmpty ? call.fanName : call.artistName,
          ),
        );
        return;
      }

      _unsubscribe = await VideoCallService.subscribe(handleRealtime);
      final join = await CometChatCallService.join(call);
      if (!mounted) {
        return;
      }
      setState(() {
        _joining = false;
        _cometWidget = join.callWidget;
        _statusMessage = join.sandbox
            ? (join.message.isEmpty
                ? 'Sandbox — vídeo remoto indisponível até configurar CometChat.'
                : join.message)
            : null;
      });
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[meet] call bootstrap: $error');
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _joining = false;
        _error = 'Falha ao entrar na chamada.';
      });
    }
  }

  void handleRealtime(VideoCallRealtimeEvent event) {
    final call = event.call;
    if (call == null || call.callId != widget.callId) {
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() => _call = call);
    if (call.isTerminal) {
      context.pushReplacement(
        Pages.meetResultOf(
          status: call.status,
          reason: call.endedReason,
          peerName: call.fanName.isNotEmpty ? call.fanName : call.artistName,
        ),
      );
    }
  }

  Future<void> handleEnd() async {
    if (_ending) {
      return;
    }
    setState(() => _ending = true);
    try {
      final call = await VideoCallService.end(widget.callId);
      await CometChatCallService.leave();
      if (!mounted) {
        return;
      }
      context.pushReplacement(
        Pages.meetResultOf(
          status: call.status,
          reason: call.endedReason.isEmpty ? 'hangup' : call.endedReason,
          peerName: call.fanName.isNotEmpty ? call.fanName : call.artistName,
        ),
      );
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[meet] end: $error');
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _ending = false;
        _error = 'Não foi possível encerrar.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final call = _call;
    final remaining = call?.remainingSeconds ?? 60;
    final peer = call == null
        ? 'Meet'
        : (call.fanName.isNotEmpty ? call.fanName : call.artistName);

    return Scaffold(
      backgroundColor: AppPalette.platinum950,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_cometWidget != null)
            _cometWidget!
          else
            ColoredBox(
              color: AppPalette.platinum950,
              child: Center(
                child: _joining
                    ? const CircularProgressIndicator(color: Colors.white)
                    : MeetPeerHeader(
                        name: peer,
                        subtitle: _statusMessage ??
                            'Conectando…',
                      ),
              ),
            ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                if (_statusMessage != null && _cometWidget == null) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      _statusMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style: const TextStyle(color: AppPalette.red300),
                  ),
                ],
                const Spacer(),
                MeetRoundActionButton(
                  icon: Icons.call_end,
                  color: AppPalette.red500,
                  label: 'Encerrar',
                  onPressed: _ending ? null : handleEnd,
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
