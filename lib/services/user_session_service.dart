import 'dart:math';

import 'package:crowdfans/api/api_urls.dart';
import 'package:crowdfans/components/profile/connected_device_row.dart';
import 'package:crowdfans/services/http_service.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _sessionIdKey = 'security.currentSessionId';

/// Sessões de aparelho (`/api/v1/me/sessions` — CF-266 / CF-216).
abstract final class UserSessionService {
  static Future<String> currentSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_sessionIdKey)?.trim() ?? '';
    if (existing.isNotEmpty) {
      return existing;
    }
    final created = _uuidV4();
    await prefs.setString(_sessionIdKey, created);
    return created;
  }

  /// Registra/renova a sessão deste aparelho no backend.
  static Future<void> syncCurrentSession() async {
    try {
      final id = await currentSessionId();
      await HttpService.request<void>(
        ApiUrls.meSessions,
        method: Method.post,
        body: {
          'id': id,
          'deviceName': _deviceName(),
          'platform': _platform(),
          'platformLine': _platformLine(),
          'location': 'Localização não disponível',
        },
      );
    } catch (_) {
      // Sync de sessão não deve derrubar login.
    }
  }

  static Future<List<ConnectedDeviceSession>> listSessions() async {
    final currentId = await currentSessionId();
    return HttpService.request<List<ConnectedDeviceSession>>(
      '${ApiUrls.meSessions}?currentId=${Uri.encodeComponent(currentId)}',
      parse: (json) {
        final map = json as Map<String, dynamic>? ?? {};
        final items = map['items'] as List? ?? const [];
        return [
          for (final item in items)
            if (item is Map<String, dynamic>) _fromJson(item),
        ];
      },
    );
  }

  static Future<void> revokeSession(String sessionId) async {
    final currentId = await currentSessionId();
    await HttpService.request<void>(
      '${ApiUrls.meSessions}/$sessionId'
      '?currentId=${Uri.encodeComponent(currentId)}',
      method: Method.delete,
    );
  }

  static Future<void> revokeOtherSessions() async {
    final currentId = await currentSessionId();
    await HttpService.request<void>(
      '${ApiUrls.meSessions}?currentId=${Uri.encodeComponent(currentId)}',
      method: Method.delete,
    );
  }

  static ConnectedDeviceSession _fromJson(Map<String, dynamic> json) {
    return ConnectedDeviceSession(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Aparelho',
      platformLine: json['platformLine'] as String? ?? 'Crowd Fans App',
      location: json['location'] as String? ?? '',
      activity: json['activity'] as String? ?? '',
      isCurrent: json['isCurrent'] == true,
      isPhone: json['isPhone'] != false,
    );
  }

  static String _platform() {
    if (kIsWeb) {
      return 'web';
    }
    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS => 'ios',
      TargetPlatform.android => 'android',
      _ => 'web',
    };
  }

  static String _deviceName() {
    if (kIsWeb) {
      return 'Navegador web';
    }
    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS => 'iPhone',
      TargetPlatform.android => 'Android',
      TargetPlatform.macOS => 'Mac',
      TargetPlatform.windows => 'Windows',
      _ => 'Este aparelho',
    };
  }

  static String _platformLine() {
    final platform = _platform();
    return switch (platform) {
      'ios' => 'Crowd Fans App · iOS',
      'android' => 'Crowd Fans App · Android',
      _ => 'Crowd Fans Web',
    };
  }

  static String _uuidV4() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    String hex(int value) => value.toRadixString(16).padLeft(2, '0');
    final h = bytes.map(hex).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-'
        '${h.substring(12, 16)}-${h.substring(16, 20)}-${h.substring(20)}';
  }
}
