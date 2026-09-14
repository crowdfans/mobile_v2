import 'dart:async';
import 'dart:convert';

import 'package:crowdfans/api/api_urls.dart';
import 'package:crowdfans/models/video_call.dart';
import 'package:crowdfans/services/api_config.dart';
import 'package:crowdfans/services/firebase_service.dart';
import 'package:crowdfans/services/http_service.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Meet 1:1 — HTTP + WS (`/api/v1/video-calls`, CF-31).
abstract final class VideoCallService {
  static Future<VideoCall> request(String artistUid) {
    return HttpService.request(
      ApiUrls.videoCalls,
      method: Method.post,
      body: {'artistUid': artistUid},
      parse: VideoCall.fromJson,
    );
  }

  static Future<List<VideoCall>> listIncoming() {
    return HttpService.request(
      ApiUrls.videoCallsIncoming,
      parse: (json) {
        final map = (json as Map?)?.cast<String, dynamic>() ?? {};
        return [
          for (final item in map['calls'] as List? ?? const [])
            VideoCall.fromJson(item),
        ];
      },
    );
  }

  static Future<VideoCall> get(String callId) {
    return HttpService.request(
      ApiUrls.withParams(ApiUrls.videoCall, {'callId': callId}),
      parse: VideoCall.fromJson,
    );
  }

  static Future<VideoCall> accept(String callId) {
    return HttpService.request(
      ApiUrls.withParams(ApiUrls.videoCallAccept, {'callId': callId}),
      method: Method.post,
      parse: VideoCall.fromJson,
    );
  }

  static Future<VideoCall> decline(String callId) {
    return HttpService.request(
      ApiUrls.withParams(ApiUrls.videoCallDecline, {'callId': callId}),
      method: Method.post,
      parse: VideoCall.fromJson,
    );
  }

  static Future<VideoCall> cancel(String callId) {
    return HttpService.request(
      ApiUrls.withParams(ApiUrls.videoCallCancel, {'callId': callId}),
      method: Method.post,
      parse: VideoCall.fromJson,
    );
  }

  static Future<VideoCall> end(String callId) {
    return HttpService.request(
      ApiUrls.withParams(ApiUrls.videoCallEnd, {'callId': callId}),
      method: Method.post,
      parse: VideoCall.fromJson,
    );
  }

  /// Assina o WS do usuário; filtra eventos `video-call.*`.
  static Future<VoidCallback> subscribe(
    void Function(VideoCallRealtimeEvent event) onEvent,
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
          final event = VideoCallRealtimeEvent.fromJson(decoded);
          if (!event.isVideoCall) {
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
