import 'dart:async';

import 'package:crowdfans/api/api_urls.dart';
import 'package:crowdfans/services/http_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Handler em isolate separado (obrigatório pelo Firebase Messaging).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Só registra o handler; o payload já chega na inbox via backend.
}

/// Registro do token FCM/APNs no backend CrowdFans.
///
/// Espelho de `mobile/src/services/notifications/push-token-service.ts`.
abstract final class PushTokenService {
  static StreamSubscription<String>? _tokenRefreshSub;
  static StreamSubscription<RemoteMessage>? _foregroundSub;
  static bool _handlerAttached = false;

  static Future<void> registerDeviceToken({
    required String token,
    required String platform,
  }) {
    return HttpService.request<void>(
      ApiUrls.notificationDeviceTokens,
      method: Method.post,
      body: {'token': token, 'platform': platform},
    );
  }

  static Future<void> unregisterDeviceToken(String token) {
    final path =
        '${ApiUrls.notificationDeviceTokens}?token=${Uri.encodeComponent(token)}';
    return HttpService.request<void>(path, method: Method.delete);
  }

  static String platformForPush() {
    if (kIsWeb) {
      return 'web';
    }
    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS => 'ios',
      TargetPlatform.android => 'android',
      _ => 'web',
    };
  }

  /// Pede permissão, obtém o token nativo e envia ao backend.
  ///
  /// Web e falhas silenciosas (igual ao Expo): não bloqueiam a sessão.
  static Future<void> syncPushTokenWithBackend() async {
    if (kIsWeb) {
      return;
    }
    try {
      final granted = await _ensurePermission();
      if (!granted) {
        return;
      }

      final messaging = FirebaseMessaging.instance;
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      final token = await messaging.getToken();
      if (token == null || token.isEmpty) {
        return;
      }

      await registerDeviceToken(token: token, platform: platformForPush());
    } catch (_) {
      // Sync de push não deve derrubar login / refresh de sessão.
    }
  }

  /// Listeners de foreground + refresh de token (idempotente).
  static VoidCallback attachForegroundNotificationHandler() {
    if (kIsWeb || _handlerAttached) {
      return () {};
    }
    _handlerAttached = true;

    _foregroundSub = FirebaseMessaging.onMessage.listen((_) {});
    _tokenRefreshSub = FirebaseMessaging.instance.onTokenRefresh.listen((
      token,
    ) async {
      try {
        await registerDeviceToken(token: token, platform: platformForPush());
      } catch (_) {}
    });

    return () {
      unawaited(_foregroundSub?.cancel());
      unawaited(_tokenRefreshSub?.cancel());
      _foregroundSub = null;
      _tokenRefreshSub = null;
      _handlerAttached = false;
    };
  }

  static Future<bool> _ensurePermission() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      final status = await Permission.notification.status;
      if (status.isGranted) {
        return true;
      }
      final asked = await Permission.notification.request();
      return asked.isGranted;
    }

    return false;
  }
}
