import 'dart:async';

import 'package:crowdfans/constants/pages.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Navegação a partir de toque em push FCM.
///
/// Lê `targetRoute` / `route` no `data` do payload (quando o backend enviar).
/// Sem rota, abre a inbox.
abstract final class PushNavigationService {
  static StreamSubscription<RemoteMessage>? _openedSub;
  static bool _attached = false;

  /// Liga listeners ao [router] (idempotente).
  static Future<void> attach(GoRouter router) async {
    if (kIsWeb || _attached) {
      return;
    }
    _attached = true;

    _openedSub = FirebaseMessaging.onMessageOpenedApp.listen((message) {
      handleRemoteMessage(router, message);
    });

    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        handleRemoteMessage(router, initial);
      });
    }
  }

  static void detach() {
    unawaited(_openedSub?.cancel() ?? Future<void>.value());
    _openedSub = null;
    _attached = false;
  }

  static void handleRemoteMessage(GoRouter router, RemoteMessage message) {
    final location = resolveLocation(message);
    if (location == null || location.isEmpty) {
      return;
    }
    try {
      router.push(location);
    } catch (_) {
      // Rota inválida / sessão ainda carregando — ignora.
    }
  }

  /// Extrai e mapeia a rota do payload FCM.
  static String? resolveLocation(RemoteMessage message) {
    final data = message.data;
    final raw = (data['targetRoute'] ?? data['route'] ?? data['path'] ?? '')
        .toString()
        .trim();
    if (raw.isEmpty) {
      return Pages.notifications;
    }
    return Pages.fromIncomingLocation(raw);
  }
}
