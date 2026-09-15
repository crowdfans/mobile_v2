import 'dart:async';

import 'package:crowdfans/components/meet/meet_event_call_chrome.dart';
import 'package:crowdfans/components/meet/meet_shared.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/meet_event.dart';
import 'package:crowdfans/services/comet_chat_call_service.dart';
import 'package:crowdfans/services/meet_event_service.dart';
import 'package:crowdfans/utils/meet_call_warnings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

/// Call ativa 90s do fã — sem Hang Up; beeps aos 60s/80s (CF-150).
class MeetEventCallScreen extends StatefulWidget {
  const MeetEventCallScreen({
    super.key,
    required this.callId,
    this.warningPlayer,
  });

  final String callId;

  /// Injeta player de beep (testes). Default: [SystemSound].
  final void Function(MeetCallWarning warning)? warningPlayer;

  @override
  State<MeetEventCallScreen> createState() => _MeetEventCallScreenState();
}

class _MeetEventCallScreenState extends State<MeetEventCallScreen> {
  MeetCall? _call;
  Widget? _cometWidget;
  String? _statusMessage;
  String? _error;
  var _joining = true;
  VoidCallback? _unsubscribe;
  Timer? _localTick;
  final _warnings = MeetCallWarningTracker();

  @override
  void initState() {
    super.initState();
    handleBootstrap();
  }

  @override
  void dispose() {
    _localTick?.cancel();
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

      final call = await MeetEventService.getCall(widget.callId);
      if (!mounted) {
        return;
      }
      setState(() => _call = call);
      if (call.isTerminal) {
        context.pushReplacement(
          Pages.meetResultOf(
            status: call.status,
            reason: call.endedReason,
            peerName: call.artistName,
          ),
        );
        return;
      }

      _unsubscribe = await MeetEventService.subscribe(handleRealtime);
      handleArmLocalTick();
      final join = await CometChatCallService.joinMeet(call);
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
        debugPrint('[meet-event] call bootstrap: $error');
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

  void handleArmLocalTick() {
    _localTick?.cancel();
    _localTick = Timer.periodic(const Duration(seconds: 1), (_) {
      final call = _call;
      if (call == null || !call.isActive || !mounted) {
        return;
      }
      final next = call.remainingSeconds - 1;
      final remaining = next < 0 ? 0 : next;
      setState(() => _call = call.copyWithRemaining(remaining));
      handleWarnings(call.durationSeconds, remaining);
      if (remaining == 0) {
        // Servidor encerra; se o WS atrasar, atualiza.
        unawaited(handleRefreshTerminal());
      }
    });
  }

  void handleWarnings(int durationSeconds, int remainingSeconds) {
    final elapsed = MeetCallWarningTracker.elapsedFromRemaining(
      durationSeconds,
      remainingSeconds,
    );
    final fired = _warnings.consume(elapsedSeconds: elapsed);
    for (final warning in fired) {
      final player = widget.warningPlayer;
      if (player != null) {
        player(warning);
      } else {
        SystemSound.play(SystemSoundType.alert);
      }
    }
  }

  Future<void> handleRefreshTerminal() async {
    try {
      final call = await MeetEventService.getCall(widget.callId);
      if (!mounted) {
        return;
      }
      if (call.isTerminal) {
        context.pushReplacement(
          Pages.meetResultOf(
            status: call.status,
            reason: call.endedReason,
            peerName: call.artistName,
          ),
        );
      }
    } catch (_) {}
  }

  void handleRealtime(MeetRealtimeEvent event) {
    if (event.callId != null &&
        event.callId != widget.callId &&
        event.callId!.isNotEmpty) {
      return;
    }
    if (event.type == 'meet-call.ended' || event.type == 'meet-call.missed') {
      if (!mounted) {
        return;
      }
      context.pushReplacement(
        Pages.meetResultOf(
          status: event.status ?? 'ended',
          peerName: _call?.artistName ?? '',
        ),
      );
      return;
    }
    final call = event.call;
    if (call == null || call.callId != widget.callId) {
      if (event.remainingSeconds != null && _call != null) {
        setState(
          () => _call = _call!.copyWithRemaining(event.remainingSeconds!),
        );
        handleWarnings(_call!.durationSeconds, event.remainingSeconds!);
      }
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() => _call = call);
    handleWarnings(call.durationSeconds, call.remainingSeconds);
    if (call.isTerminal) {
      context.pushReplacement(
        Pages.meetResultOf(
          status: call.status,
          reason: call.endedReason,
          peerName: call.artistName,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final call = _call;
    final remaining = call?.remainingSeconds ?? 90;
    final peer = call?.artistName ?? 'Meet';

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
                        subtitle: _statusMessage ?? 'Conectando…',
                      ),
              ),
            ),
          MeetEventCallChrome(
            peerName: peer,
            remainingSeconds: remaining,
            joining: false,
            statusMessage: _cometWidget == null ? _statusMessage : null,
            error: _error,
          ),
        ],
      ),
    );
  }
}
