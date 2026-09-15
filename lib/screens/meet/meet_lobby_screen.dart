import 'dart:async';

import 'package:crowdfans/components/meet/meet_lobby_membership_paywall.dart';
import 'package:crowdfans/components/meet/meet_lobby_queue_panel.dart';
import 'package:crowdfans/components/toolbar/toolbar_back_button.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/meet_event.dart';
import 'package:crowdfans/services/meet_event_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Lobby do Meet & Greet Virtual — countdown, paywall e fila (CF-150).
class MeetLobbyScreen extends StatefulWidget {
  const MeetLobbyScreen({
    super.key,
    required this.eventId,
    this.artistName,
    this.avatarUrl,
  });

  final String eventId;
  final String? artistName;
  final String? avatarUrl;

  @override
  State<MeetLobbyScreen> createState() => _MeetLobbyScreenState();
}

class _MeetLobbyScreenState extends State<MeetLobbyScreen> {
  MeetEventSnapshot? _snapshot;
  String? _error;
  var _loading = true;
  var _busy = false;
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
        debugPrint('[meet-event] lobby: $error');
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = 'Não foi possível carregar o lobby.';
      });
    }
  }

  void handleArmTimers() {
    _tick?.cancel();
    _poll?.cancel();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      final snap = _snapshot;
      if (snap == null || !mounted) {
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
    } catch (_) {
      // Mantém último snapshot.
    }
  }

  void handleRealtime(MeetRealtimeEvent event) {
    if (!mounted) {
      return;
    }
    if (event.isIncoming && (event.callId ?? '').isNotEmpty) {
      final callId = event.callId!;
      final name = (_snapshot?.artistName.isNotEmpty == true)
          ? _snapshot!.artistName
          : (widget.artistName ?? '');
      context.push(
        Pages.meetEventRingingOf(
          callId,
          artistName: name,
          avatarUrl: widget.avatarUrl,
        ),
      );
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
    unawaited(handleRefresh());
  }

  void handleFinished() {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Este Meet & Greet foi encerrado.')),
    );
    handleBack();
  }

  void handleBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(Pages.home);
  }

  Future<void> handleJoinQueue() async {
    if (_busy) {
      return;
    }
    setState(() => _busy = true);
    try {
      final snap = await MeetEventService.joinQueue(widget.eventId);
      if (!mounted) {
        return;
      }
      setState(() {
        _snapshot = snap;
        _busy = false;
        _error = null;
      });
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[meet-event] join: $error');
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _busy = false;
        _error = 'Não foi possível entrar na fila. Verifique sua membership.';
      });
    }
  }

  Future<void> handleLeaveQueue() async {
    if (_busy) {
      return;
    }
    setState(() => _busy = true);
    try {
      final snap = await MeetEventService.leaveQueue(widget.eventId);
      if (!mounted) {
        return;
      }
      setState(() {
        _snapshot = snap;
        _busy = false;
      });
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[meet-event] leave: $error');
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _busy = false;
        _error = 'Não foi possível sair da fila.';
      });
    }
  }

  void handleSubscribeMembership() {
    final artistUid = _snapshot?.artistUid ?? '';
    if (artistUid.isEmpty) {
      return;
    }
    context.push(Pages.artistProfileOf(artistUid));
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final snap = _snapshot;
    final titleName = (snap?.artistName.trim().isNotEmpty == true)
        ? snap!.artistName.trim()
        : (widget.artistName ?? '').trim();
    final title = titleName.isEmpty
        ? 'Meet & Greet'
        : 'Meet & Greet · $titleName';

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ToolbarBackButton(onPressed: handleBack),
              Text(
                title,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              if (_loading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (snap == null)
                Expanded(
                  child: Center(
                    child: Text(
                      _error ?? 'Lobby indisponível.',
                      style: TextStyle(color: colors.textSecondary),
                    ),
                  ),
                )
              else ...[
                if (_error != null) ...[
                  Text(
                    _error!,
                    style: const TextStyle(color: AppPalette.red500),
                  ),
                  const SizedBox(height: 12),
                ],
                Expanded(
                  child: SingleChildScrollView(
                    child: snap.hasMembership
                        ? MeetLobbyQueuePanel(
                            snapshot: snap,
                            busy: _busy,
                            onJoinQueue: handleJoinQueue,
                            onLeaveQueue: handleLeaveQueue,
                          )
                        : MeetLobbyMembershipPaywall(
                            artistName: titleName,
                            onSubscribe: handleSubscribeMembership,
                          ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
