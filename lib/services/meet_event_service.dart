import 'dart:async';
import 'dart:convert';

import 'package:crowdfans/api/api_urls.dart';
import 'package:crowdfans/models/meet_event.dart';
import 'package:crowdfans/services/api_config.dart';
import 'package:crowdfans/services/firebase_service.dart';
import 'package:crowdfans/services/http_service.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Cliente HTTP + WS do Meet & Greet Virtual (CF-150).
abstract final class MeetEventService {
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
