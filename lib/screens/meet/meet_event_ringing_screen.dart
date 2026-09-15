import 'dart:async';

import 'package:crowdfans/components/meet/meet_shared.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/meet_event.dart';
import 'package:crowdfans/services/meet_event_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Fã recebe inbound do Meet & Greet Virtual (answer em 30s).
class MeetEventRingingScreen extends StatefulWidget {
  const MeetEventRingingScreen({
    super.key,
    required this.callId,
    this.artistName,
    this.avatarUrl,
  });

  final String callId;
  final String? artistName;
  final String? avatarUrl;

  @override
  State<MeetEventRingingScreen> createState() => _MeetEventRingingScreenState();
}

class _MeetEventRingingScreenState extends State<MeetEventRingingScreen> {
  MeetCall? _call;
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
      final call = await MeetEventService.getCall(widget.callId);
      if (!mounted) {
        return;
      }
      setState(() => _call = call);
      if (call.isActive) {
        context.pushReplacement(Pages.meetEventCallOf(call.callId));
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
        return;
      }
      _unsubscribe = await MeetEventService.subscribe(handleRealtime);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _error = 'Não foi possível carregar a chamada.');
    }
  }

  void handleRealtime(MeetRealtimeEvent event) {
    if (event.callId != null &&
        event.callId != widget.callId &&
        event.callId!.isNotEmpty) {
      return;
    }
    final call = event.call;
    if (call == null || call.callId != widget.callId) {
      if (event.type == 'meet-call.started') {
        context.pushReplacement(Pages.meetEventCallOf(widget.callId));
      }
      if (event.type == 'meet-call.missed' || event.type == 'meet-call.ended') {
        context.pushReplacement(
          Pages.meetResultOf(
            status: event.status ?? 'missed',
            peerName: widget.artistName ?? '',
          ),
        );
      }
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() => _call = call);
    if (call.isActive) {
      context.pushReplacement(Pages.meetEventCallOf(call.callId));
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

  Future<void> handleAnswer() async {
    if (_busy) {
      return;
    }
    setState(() => _busy = true);
    try {
      final call = await MeetEventService.answer(widget.callId);
      if (!mounted) {
        return;
      }
      context.pushReplacement(Pages.meetEventCallOf(call.callId));
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[meet-event] answer: $error');
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

  Future<void> handleMiss() async {
    if (_busy) {
      return;
    }
    setState(() => _busy = true);
    try {
      final call = await MeetEventService.miss(widget.callId);
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
        debugPrint('[meet-event] miss: $error');
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
              subtitle: 'Meet & Greet de 90 segundos — atenda em até 30s',
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
                  onPressed: _busy ? null : handleMiss,
                ),
                MeetRoundActionButton(
                  icon: Icons.call,
                  color: AppPalette.green500,
                  label: 'Atender',
                  onPressed: _busy ? null : handleAnswer,
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
