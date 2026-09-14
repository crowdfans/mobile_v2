import 'dart:async';

import 'package:crowdfans/components/meet/meet_shared.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/video_call.dart';
import 'package:crowdfans/services/video_call_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Hub do artista — lista chamadas entrantes e escuta WS.
class MeetHostScreen extends StatefulWidget {
  const MeetHostScreen({super.key});

  @override
  State<MeetHostScreen> createState() => _MeetHostScreenState();
}

class _MeetHostScreenState extends State<MeetHostScreen> {
  var _loading = true;
  String? _error;
  var _calls = <VideoCall>[];
  VoidCallback? _unsubscribe;
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    handleBootstrap();
  }

  @override
  void dispose() {
    _poll?.cancel();
    _unsubscribe?.call();
    super.dispose();
  }

  Future<void> handleBootstrap() async {
    await handleRefresh();
    _unsubscribe = await VideoCallService.subscribe(handleRealtime);
    _poll = Timer.periodic(const Duration(seconds: 8), (_) {
      unawaited(handleRefresh(silent: true));
    });
  }

  Future<void> handleRefresh({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final calls = await VideoCallService.listIncoming();
      if (!mounted) {
        return;
      }
      setState(() {
        _calls = calls;
        _loading = false;
      });
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[meet] incoming: $error');
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        if (!silent) {
          _error = 'Não foi possível carregar chamadas.';
        }
      });
    }
  }

  void handleRealtime(VideoCallRealtimeEvent event) {
    if (event.type == 'video-call.incoming' && event.call != null) {
      if (!mounted) {
        return;
      }
      context.push(Pages.meetRingingOf(event.call!.callId));
      return;
    }
    unawaited(handleRefresh(silent: true));
  }

  void handleOpen(VideoCall call) {
    context.push(Pages.meetRingingOf(call.callId, fanName: call.fanName));
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
    return MeetScreenFrame(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: handleBack,
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const Expanded(
                  child: Text(
                    'Meet & Greet',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => handleRefresh(),
                  icon: const Icon(Icons.refresh, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Quando um superfã solicitar, a chamada aparece aqui.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 20),
            if (_loading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              )
            else if (_error != null)
              Expanded(
                child: Center(
                  child: Text(
                    _error!,
                    style: const TextStyle(color: AppPalette.red300),
                  ),
                ),
              )
            else if (_calls.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'Nenhuma chamada na fila.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: _calls.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final call = _calls[index];
                    return ListTile(
                      onTap: () => handleOpen(call),
                      tileColor: Colors.white10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      title: Text(
                        call.fanName.isEmpty ? 'Superfã' : call.fanName,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        '${call.jamCoins} JC · ${call.durationSeconds}s',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Colors.white70,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
