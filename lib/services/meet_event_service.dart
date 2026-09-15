import 'dart:async';
import 'dart:convert';

import 'package:crowdfans/api/api_urls.dart';
import 'package:crowdfans/models/meet_event.dart';
import 'package:crowdfans/services/api_config.dart';
import 'package:crowdfans/services/firebase_service.dart';
import 'package:crowdfans/services/http_service.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Cliente HTTP + WS do Meet & Greet Virtual (CF-150 / CF-151).
abstract final class MeetEventService {
  static const _activeEventKey = 'meet_event_active_id';
  static const _lastCallKey = 'meet_event_last_call_id';

  static Future<MeetEventSnapshot> create() {
    return HttpService.request(
      ApiUrls.meetEvents,
      method: Method.post,
      parse: MeetEventSnapshot.fromJson,
    ).then((snap) async {
      await rememberActiveEvent(snap.eventId);
      return snap;
    });
  }

  static Future<MeetEventSnapshot> get(String eventId) {
    return HttpService.request(
      ApiUrls.withParams(ApiUrls.meetEvent, {'eventId': eventId}),
      parse: MeetEventSnapshot.fromJson,
    );
  }

  static Future<MeetEventSnapshot> joinQueue(String eventId) {
    return HttpService.request(
      ApiUrls.withParams(ApiUrls.meetEventJoinQueue, {'eventId': eventId}),
      method: Method.post,
      parse: MeetEventSnapshot.fromJson,
    );
  }

  static Future<MeetEventSnapshot> leaveQueue(String eventId) {
    return HttpService.request(
      ApiUrls.withParams(ApiUrls.meetEventLeaveQueue, {'eventId': eventId}),
      method: Method.post,
      parse: MeetEventSnapshot.fromJson,
    );
  }

  static Future<MeetEventSnapshot> startServing(String eventId) {
    return HttpService.request(
      ApiUrls.withParams(ApiUrls.meetEventStartServing, {'eventId': eventId}),
      method: Method.post,
      parse: MeetEventSnapshot.fromJson,
    );
  }

  static Future<MeetCall> callNext(String eventId) {
    return HttpService.request(
      ApiUrls.withParams(ApiUrls.meetEventCallNext, {'eventId': eventId}),
      method: Method.post,
      parse: MeetCall.fromJson,
    ).then((call) async {
      await rememberLastCall(call.callId);
      return call;
    });
  }

  static Future<MeetEventSnapshot> finish(String eventId) {
    return HttpService.request(
      ApiUrls.withParams(ApiUrls.meetEventFinish, {'eventId': eventId}),
      method: Method.post,
      parse: MeetEventSnapshot.fromJson,
    ).then((snap) async {
      await clearActiveEvent();
      return snap;
    });
  }

  static Future<MeetCall> getCall(String callId) {
    return HttpService.request(
      ApiUrls.withParams(ApiUrls.meetEventCall, {'callId': callId}),
      parse: MeetCall.fromJson,
    );
  }

  static Future<MeetCall> answer(String callId) {
    return HttpService.request(
      ApiUrls.withParams(ApiUrls.meetEventCallAnswer, {'callId': callId}),
      method: Method.post,
      parse: MeetCall.fromJson,
    );
  }

  static Future<MeetCall> miss(String callId) {
    return HttpService.request(
      ApiUrls.withParams(ApiUrls.meetEventCallMiss, {'callId': callId}),
      method: Method.post,
      parse: MeetCall.fromJson,
    );
  }

  static Future<MeetCall> end(String callId) {
    return HttpService.request(
      ApiUrls.withParams(ApiUrls.meetEventCallEnd, {'callId': callId}),
      method: Method.post,
      parse: MeetCall.fromJson,
    );
  }

  static Future<MeetEventSnapshot> earlyEndReport(
    String callId, {
    required String reason,
    String details = '',
  }) {
    return HttpService.request(
      ApiUrls.withParams(ApiUrls.meetEventCallEarlyEndReport, {
        'callId': callId,
      }),
      method: Method.post,
      body: {'reason': reason, 'details': details},
      parse: MeetEventSnapshot.fromJson,
    );
  }

  /// Retoma evento aberto gravado localmente (create 409 / reentrada).
  static Future<String?> activeEventId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_activeEventKey)?.trim() ?? '';
    return id.isEmpty ? null : id;
  }

  static Future<void> rememberActiveEvent(String eventId) async {
    final id = eventId.trim();
    if (id.isEmpty) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeEventKey, id);
  }

  static Future<void> clearActiveEvent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeEventKey);
    await prefs.remove(_lastCallKey);
  }

  static Future<String?> lastCallId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_lastCallKey)?.trim() ?? '';
    return id.isEmpty ? null : id;
  }

  static Future<void> rememberLastCall(String callId) async {
    final id = callId.trim();
    if (id.isEmpty) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastCallKey, id);
  }

  /// Cria evento ou retoma o aberto (preferência local + GET).
  static Future<MeetEventSnapshot> createOrResume() async {
    try {
      return await create();
    } catch (_) {
      final stored = await activeEventId();
      if (stored == null) {
        rethrow;
      }
      final snap = await get(stored);
      if (snap.isFinished) {
        await clearActiveEvent();
        return create();
      }
      return snap;
    }
  }

  /// Assina `/me/ws` e filtra `meet-event.*` / `meet-call.*`.
  static Future<VoidCallback> subscribe(
    void Function(MeetRealtimeEvent event) onEvent,
  ) async {
    final token = await FirebaseService.currentIdToken();
    if (token == null || token.isEmpty) {
      return () {};
    }
    final httpBase = apiBaseUrl().replaceAll(RegExp(r'/$'), '');
    final wsBase = httpBase.replaceFirst(
      RegExp(r'^http', caseSensitive: false),
      'ws',
    );
    final uri = Uri.parse(
      '$wsBase${ApiUrls.meWs}?token=${Uri.encodeComponent(token)}',
    );
    final channel = WebSocketChannel.connect(uri);
    final sub = channel.stream.listen(
      (message) {
        try {
          final decoded = jsonDecode(message.toString());
          final event = MeetRealtimeEvent.fromJson(decoded);
          if (!event.isMeetEvent && !event.isMeetCall) {
            return;
          }
          onEvent(event);
        } catch (_) {
          // Ignora frames inválidos.
        }
      },
      onError: (_) {},
      cancelOnError: false,
    );
    return () {
      unawaited(sub.cancel());
      unawaited(channel.sink.close());
    };
  }
}
