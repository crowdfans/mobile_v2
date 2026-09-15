import 'dart:async';

import 'package:crowdfans/api/api_error.dart';
import 'package:crowdfans/components/meet/meet_host_lobby_panel.dart';
import 'package:crowdfans/components/meet/meet_host_serving_panel.dart';
import 'package:crowdfans/components/toolbar/toolbar_back_button.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/meet_event.dart';
import 'package:crowdfans/services/meet_event_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Hub do artista — gate, call_next, report e finish (CF-151).
class MeetEventHostScreen extends StatefulWidget {
  const MeetEventHostScreen({super.key, required this.eventId});

  final String eventId;

  @override
  State<MeetEventHostScreen> createState() => _MeetEventHostScreenState();
}

class _MeetEventHostScreenState extends State<MeetEventHostScreen> {
  MeetEventSnapshot? _snapshot;
  String? _error;
  var _loading = true;
  var _busy = false;
  String? _pendingReportCallId;
  VoidCallback? _unsubscribe;
  Timer? _tick;
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    handleBootstrap();
  }

  @override
  void dispose() {
    _tick?.cancel();
    _poll?.cancel();
    _unsubscribe?.call();
    super.dispose();
  }

  Future<void> handleBootstrap() async {
    try {
      await MeetEventService.rememberActiveEvent(widget.eventId);
      final snap = await MeetEventService.get(widget.eventId);
      if (!mounted) {
        return;
      }
      setState(() {
        _snapshot = snap;
        _loading = false;
        _error = null;
      });
      handleArmTimers();
      _unsubscribe = await MeetEventService.subscribe(handleRealtime);
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[meet-event] host: $error');
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = 'Não foi possível carregar o evento.';
      });
    }
  }

  void handleArmTimers() {
    _tick?.cancel();
    _poll?.cancel();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      final snap = _snapshot;
      if (snap == null || !mounted || !snap.isLobby) {
        return;
      }
      if (snap.lobbyRemainingSeconds <= 0) {
        return;
      }
      setState(() {
        _snapshot = snap.copyWithCountdown(snap.lobbyRemainingSeconds - 1);
      });
    });
    _poll = Timer.periodic(const Duration(seconds: 8), (_) {
      unawaited(handleRefresh());
    });
  }

  Future<void> handleRefresh() async {
    try {
      final snap = await MeetEventService.get(widget.eventId);
      if (!mounted) {
        return;
      }
      setState(() {
        _snapshot = snap;
        _error = null;
      });
      if (snap.isFinished) {
        handleFinished();
      }
    } catch (_) {}
  }

  void handleRealtime(MeetRealtimeEvent event) {
    if (!mounted) {
      return;
    }
    if (event.eventId != null &&
        event.eventId != widget.eventId &&
        event.eventId!.isNotEmpty) {
      return;
    }
    if (event.type == 'meet-event.finished') {
      handleFinished();
      return;
    }
    if (event.snapshot != null) {
      setState(() => _snapshot = event.snapshot);
      return;
    }
    unawaited(handleRefresh());
  }

  void handleFinished() {
    unawaited(MeetEventService.clearActiveEvent());
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Meet & Greet encerrado.')),
    );
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(Pages.home);
  }

  Future<void> handleStartServing() async {
    if (_busy) {
      return;
    }
    setState(() => _busy = true);
    try {
      final snap = await MeetEventService.startServing(widget.eventId);
      if (!mounted) {
        return;
      }
      setState(() {
        _snapshot = snap;
        _busy = false;
      });
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[meet-event] startServing: $error');
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _busy = false;
        _error = error is ApiError
            ? error.message
            : 'Não foi possível iniciar o atendimento.';
      });
    }
  }

  Future<void> handleCallNext() async {
    if (_busy) {
      return;
    }
    setState(() => _busy = true);
    try {
      final call = await MeetEventService.callNext(widget.eventId);
      if (!mounted) {
        return;
      }
      setState(() => _busy = false);
      _pendingReportCallId = call.callId;
      await context.push(
        Pages.meetEventHostRingingOf(call.callId, fanName: call.fanName),
      );
      if (!mounted) {
        return;
      }
      await handleRefresh();
      if (!mounted) {
        return;
      }
      final snap = _snapshot;
      if (snap?.pendingEarlyEndReport == true &&
          (_pendingReportCallId ?? '').isNotEmpty) {
        await context.push(
          Pages.meetEventEarlyEndReportOf(
            _pendingReportCallId!,
            eventId: widget.eventId,
          ),
        );
        if (mounted) {
          await handleRefresh();
        }
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[meet-event] callNext: $error');
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _busy = false;
        _error = error is ApiError
            ? error.message
            : 'Não foi possível chamar o próximo.';
      });
    }
  }

  Future<void> handleFinish() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Encerrar Meet & Greet?'),
        content: const Text(
          'A fila será derrubada e o evento ficará finalizado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Encerrar'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) {
      return;
    }
    if (_busy) {
      return;
    }
    setState(() => _busy = true);
    try {
      await MeetEventService.finish(widget.eventId);
      if (!mounted) {
        return;
      }
      handleFinished();
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[meet-event] finish: $error');
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _busy = false;
        _error = error is ApiError
            ? error.message
            : 'Não foi possível encerrar o evento.';
      });
    }
  }

  Future<void> handleOpenReport() async {
    final callId =
        _pendingReportCallId ?? await MeetEventService.lastCallId();
    if (callId == null || callId.isEmpty) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Abra o report a partir da última chamada.'),
        ),
      );
      return;
    }
    if (!mounted) {
      return;
    }
    await context.push(
      Pages.meetEventEarlyEndReportOf(callId, eventId: widget.eventId),
    );
    if (mounted) {
      await handleRefresh();
    }
  }

  void handleBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(Pages.home);
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final snap = _snapshot;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        leading: ToolbarBackButton(onPressed: handleBack),
        title: const Text('Meet & Greet'),
        actions: [
          IconButton(
            onPressed: _loading ? null : handleRefresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null && snap == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.textSecondary),
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                  children: [
                    if (_error != null) ...[
                      Text(
                        _error!,
                        style: const TextStyle(color: AppPalette.red500),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (snap != null && snap.isLobby)
                      MeetHostLobbyPanel(
                        snapshot: snap,
                        busy: _busy,
                        onStartServing: handleStartServing,
                        onFinish: handleFinish,
                      ),
                    if (snap != null && snap.isServing)
                      MeetHostServingPanel(
                        snapshot: snap,
                        busy: _busy,
                        onCallNext: handleCallNext,
                        onFinish: handleFinish,
                        onOpenReport: handleOpenReport,
                      ),
                    if (snap != null && snap.isFinished)
                      Text(
                        'Evento finalizado.',
                        style: TextStyle(color: colors.textSecondary),
                      ),
                  ],
                ),
    );
  }
}
