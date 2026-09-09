import 'dart:async';
import 'dart:convert';

import 'package:crowdfans/api/api_urls.dart';
import 'package:crowdfans/services/api_config.dart';
import 'package:crowdfans/services/firebase_service.dart';
import 'package:crowdfans/services/http_service.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Pacote de Jam Coins.
class JamCoinPack {
  const JamCoinPack({
    required this.id,
    required this.coins,
    required this.priceCents,
    required this.label,
    this.sandboxOnly = false,
  });

  final String id;
  final int coins;
  final int priceCents;
  final String label;
  final bool sandboxOnly;

  factory JamCoinPack.fromJson(Object? json) {
    final map = (json as Map?)?.cast<String, dynamic>() ?? {};
    return JamCoinPack(
      id: map['id']?.toString() ?? '',
      coins: (map['coins'] as num?)?.toInt() ?? 0,
      priceCents: (map['priceCents'] as num?)?.toInt() ?? 0,
      label: map['label']?.toString() ?? '',
      sandboxOnly: map['sandboxOnly'] == true,
    );
  }
}

/// Saldo e pacotes da carteira.
class WalletSnapshot {
  const WalletSnapshot({
    this.balance = 0,
    this.jamCoinsBalance = '0',
    this.packs = const [],
  });

  final int balance;
  final String jamCoinsBalance;
  final List<JamCoinPack> packs;

  String get displayBalance {
    final labeled = jamCoinsBalance.trim();
    if (labeled.isNotEmpty) {
      return labeled;
    }
    return '$balance';
  }

  factory WalletSnapshot.fromJson(Object? json) {
    final map = (json as Map?)?.cast<String, dynamic>() ?? {};
    return WalletSnapshot(
      balance: (map['balance'] as num?)?.toInt() ?? 0,
      jamCoinsBalance: map['jamCoinsBalance']?.toString() ?? '0',
      packs: [
        for (final item in map['packs'] as List? ?? const [])
          JamCoinPack.fromJson(item),
      ],
    );
  }
}

/// Resultado do checkout sandbox.
class WalletCheckoutResult {
  const WalletCheckoutResult({
    required this.checkoutId,
    required this.packId,
    required this.coins,
    required this.status,
    required this.provider,
    this.pixCopyPaste,
    this.message,
  });

  final String checkoutId;
  final String packId;
  final int coins;
  final String status;
  final String provider;
  final String? pixCopyPaste;
  final String? message;

  factory WalletCheckoutResult.fromJson(Object? json) {
    final map = (json as Map?)?.cast<String, dynamic>() ?? {};
    return WalletCheckoutResult(
      checkoutId: map['checkoutId']?.toString() ?? '',
      packId: map['packId']?.toString() ?? '',
      coins: (map['coins'] as num?)?.toInt() ?? 0,
      status: map['status']?.toString() ?? '',
      provider: map['provider']?.toString() ?? '',
      pixCopyPaste: map['pixCopyPaste'] as String?,
      message: map['message'] as String?,
    );
  }
}

/// Evento em tempo real da carteira (`GET /api/v1/me/ws`).
class WalletRealtimeEvent {
  const WalletRealtimeEvent({required this.type, this.data});

  final String type;
  final Object? data;

  factory WalletRealtimeEvent.fromJson(Object? json) {
    final map = (json as Map?)?.cast<String, dynamic>() ?? {};
    return WalletRealtimeEvent(
      type: map['type']?.toString() ?? '',
      data: map['data'],
    );
  }
}

/// Carteira Jam Coins (`GET /api/v1/me/wallet`).
abstract final class WalletService {
  static Future<WalletSnapshot> getWallet() {
    return HttpService.request(
      ApiUrls.meWallet,
      parse: WalletSnapshot.fromJson,
    );
  }

  static Future<List<JamCoinPack>> listPacks() {
    return HttpService.request(
      ApiUrls.jamCoinPacks,
      requireAuth: false,
      parse: (json) {
        final map = (json as Map?)?.cast<String, dynamic>() ?? {};
        return [
          for (final item in map['packs'] as List? ?? const [])
            JamCoinPack.fromJson(item),
        ];
      },
    );
  }

  static Future<WalletCheckoutResult> checkout(String packId) {
    return HttpService.request(
      ApiUrls.meWalletCheckout,
      method: Method.post,
      body: {'packId': packId},
      parse: WalletCheckoutResult.fromJson,
    );
  }

  /// Assina o WS da carteira; retorna cleanup (espelho Expo).
  static Future<VoidCallback> subscribe(
    void Function(WalletRealtimeEvent event) onEvent,
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
          onEvent(WalletRealtimeEvent.fromJson(decoded));
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
