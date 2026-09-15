import 'dart:async';

import 'package:crowdfans/components/meet/meet_shared.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/meet_event.dart';
import 'package:crowdfans/services/meet_event_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Artista aguarda o fã atender (ring 30s) após `call_next`.
class MeetEventHostRingingScreen extends StatefulWidget {
  const MeetEventHostRingingScreen({
    super.key,
    required this.callId,
    this.fanName,
    this.avatarUrl,
  });

  final String callId;
  final String? fanName;
  final String? avatarUrl;

  @override
  State<MeetEventHostRingingScreen> createState() =>
      _MeetEventHostRingingScreenState();
}

class _MeetEventHostRingingScreenState
    extends State<MeetEventHostRingingScreen> {
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
        context.pushReplacement(
          Pages.meetEventCallOf(call.callId, isArtist: true),
        );
        return;
      }
      if (call.isTerminal) {
        handleReturnToHost(call.eventId);
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
    if (event.type == 'meet-call.started') {
      context.pushReplacement(
        Pages.meetEventCallOf(widget.callId, isArtist: true),
      );
      return;
    }
    if (event.type == 'meet-call.missed' || event.type == 'meet-call.ended') {
      final eventId = event.call?.eventId ?? _call?.eventId ?? '';
      handleReturnToHost(eventId);
      return;
    }
    final call = event.call;
    if (call == null || call.callId != widget.callId) {
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() => _call = call);
    if (call.isActive) {
      context.pushReplacement(
        Pages.meetEventCallOf(call.callId, isArtist: true),
      );
    } else if (call.isTerminal) {
      handleReturnToHost(call.eventId);
    }
  }

  void handleReturnToHost(String eventId) {
    if (!mounted) {
      return;
    }
    if (eventId.isNotEmpty) {
      context.go(Pages.meetEventHostOf(eventId));
      return;
    }
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(Pages.meetHost);
  }

  Future<void> handleCancelRing() async {
    if (_busy) {
      return;
    }
    setState(() => _busy = true);
    try {
      final call = await MeetEventService.end(widget.callId);
      if (!mounted) {
        return;
      }
      handleReturnToHost(call.eventId);
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[meet-event] host cancel ring: $error');
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
    final name = (widget.fanName ?? _call?.fanName ?? '').trim();
    return MeetScreenFrame(
      imageUrl: widget.avatarUrl,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            MeetPeerHeader(
              name: name.isEmpty ? 'Superfã' : name,
              imageUrl: widget.avatarUrl,
              subtitle: 'Chamando… (até 30s)',
            ),
            const Spacer(),
            if (_error != null)
              Text(
                _error!,
                style: const TextStyle(color: AppPalette.red300),
              ),
            MeetRoundActionButton(
              icon: Icons.call_end,
              color: AppPalette.red500,
              label: _busy ? 'Cancelando…' : 'Cancelar',
              onPressed: _busy ? null : handleCancelRing,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
