import 'dart:async';

import 'package:crowdfans/components/meet/meet_shared.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/video_call.dart';
import 'package:crowdfans/services/video_call_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Fã aguarda o artista aceitar.
class MeetWaitingScreen extends StatefulWidget {
  const MeetWaitingScreen({
    super.key,
    required this.callId,
    this.artistName,
    this.avatarUrl,
  });

  final String callId;
  final String? artistName;
  final String? avatarUrl;

  @override
  State<MeetWaitingScreen> createState() => _MeetWaitingScreenState();
}

class _MeetWaitingScreenState extends State<MeetWaitingScreen> {
  VideoCall? _call;
  String? _error;
  var _busy = false;
  VoidCallback? _unsubscribe;

  @override
  void initState() {
    super.initState();
    handleBootstrap();
  }

  @override
  void dispose() {
    _unsubscribe?.call();
    super.dispose();
  }

  Future<void> handleBootstrap() async {
    try {
      final call = await VideoCallService.get(widget.callId);
      if (!mounted) {
        return;
      }
      setState(() => _call = call);
      handleRouteForStatus(call);
      _unsubscribe = await VideoCallService.subscribe(handleRealtime);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _error = 'Não foi possível carregar a chamada.');
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
    handleRouteForStatus(call);
  }

  void handleRouteForStatus(VideoCall call) {
    if (call.isActive) {
      context.pushReplacement(Pages.meetCallOf(call.callId));
      return;
    }
    if (call.isTerminal) {
      context.pushReplacement(
        Pages.meetResultOf(
          status: call.status,
          reason: call.endedReason,
          peerName: widget.artistName ?? call.artistName,
        ),
      );
    }
  }

  Future<void> handleCancel() async {
    if (_busy) {
      return;
    }
    setState(() => _busy = true);
    try {
      final call = await VideoCallService.cancel(widget.callId);
      if (!mounted) {
        return;
      }
      context.pushReplacement(
        Pages.meetResultOf(
          status: call.status,
          reason: call.endedReason,
          peerName: widget.artistName ?? call.artistName,
        ),
      );
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[meet] cancel: $error');
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _busy = false;
        _error = 'Não foi possível cancelar.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = (widget.artistName ?? _call?.artistName ?? '').trim();
    return MeetScreenFrame(
      imageUrl: widget.avatarUrl,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const Spacer(),
            MeetPeerHeader(
              name: name.isEmpty ? 'Artista' : name,
              imageUrl: widget.avatarUrl,
              subtitle: 'Aguardando o artista atender…',
            ),
            const SizedBox(height: 28),
            const CircularProgressIndicator(color: AppPalette.green400),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppPalette.red300),
              ),
            ],
            const Spacer(),
            MeetRoundActionButton(
              icon: Icons.call_end,
              color: AppPalette.red500,
              label: 'Cancelar',
              onPressed: _busy ? null : handleCancel,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
