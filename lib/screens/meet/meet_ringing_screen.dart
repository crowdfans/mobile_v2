import 'dart:async';

import 'package:crowdfans/components/meet/meet_shared.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/video_call.dart';
import 'package:crowdfans/services/video_call_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Artista recebe chamada entrante (accept / decline).
class MeetRingingScreen extends StatefulWidget {
  const MeetRingingScreen({
    super.key,
    required this.callId,
    this.fanName,
    this.avatarUrl,
  });

  final String callId;
  final String? fanName;
  final String? avatarUrl;

  @override
  State<MeetRingingScreen> createState() => _MeetRingingScreenState();
}

class _MeetRingingScreenState extends State<MeetRingingScreen> {
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
      if (call.isActive) {
        context.pushReplacement(Pages.meetCallOf(call.callId));
        return;
      }
      if (call.isTerminal) {
        context.pushReplacement(
          Pages.meetResultOf(
            status: call.status,
            reason: call.endedReason,
            peerName: widget.fanName ?? call.fanName,
          ),
        );
        return;
      }
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
    if (call.isActive) {
      context.pushReplacement(Pages.meetCallOf(call.callId));
      return;
    }
    if (call.isTerminal) {
      context.pushReplacement(
        Pages.meetResultOf(
          status: call.status,
          reason: call.endedReason,
          peerName: widget.fanName ?? call.fanName,
        ),
      );
    }
  }

  Future<void> handleAccept() async {
    if (_busy) {
      return;
    }
    setState(() => _busy = true);
    try {
      final call = await VideoCallService.accept(widget.callId);
      if (!mounted) {
        return;
      }
      context.pushReplacement(Pages.meetCallOf(call.callId));
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[meet] accept: $error');
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _busy = false;
        _error = 'Não foi possível atender.';
      });
    }
  }

  Future<void> handleDecline() async {
    if (_busy) {
      return;
    }
    setState(() => _busy = true);
    try {
      final call = await VideoCallService.decline(widget.callId);
      if (!mounted) {
        return;
      }
      context.pushReplacement(
        Pages.meetResultOf(
          status: call.status,
          reason: call.endedReason,
          peerName: widget.fanName ?? call.fanName,
        ),
      );
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[meet] decline: $error');
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _busy = false;
        _error = 'Não foi possível recusar.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = (widget.fanName ?? _call?.fanName ?? '').trim();
    return MeetScreenFrame(
      imageUrl: widget.avatarUrl,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const Spacer(),
            MeetPeerHeader(
              name: name.isEmpty ? 'Superfã' : name,
              imageUrl: widget.avatarUrl,
              subtitle: 'Quer um Meet & Greet de 60 segundos',
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppPalette.red300),
              ),
            ],
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MeetRoundActionButton(
                  icon: Icons.call_end,
                  color: AppPalette.red500,
                  label: 'Recusar',
                  onPressed: _busy ? null : handleDecline,
                ),
                MeetRoundActionButton(
                  icon: Icons.call,
                  color: AppPalette.green500,
                  label: 'Atender',
                  onPressed: _busy ? null : handleAccept,
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
