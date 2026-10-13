import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Leitura de `.env` (chaves curtas Flutter: `API_*`, `FIREBASE_*`, …).

abstract final class EnvService {
  /// Carrega `.env` local; se não existir no bundle, cai no `.env.example`.
  static Future<void> load() async {
    Object? lastError;
    for (final name in ['.env', '.env.example']) {
      try {
        await dotenv.load(fileName: name);
        return;
      } catch (error) {
        lastError = error;
      }
    }
    throw StateError(
      'Não foi possível carregar .env nem .env.example: $lastError',
    );
  }

  static String? maybe(String key) {
    final value = dotenv.maybeGet(key)?.trim();
    if (value != null && value.isNotEmpty) {
      return value;
    }
    return null;
  }

  static String get(String key, [String fallback = '']) {
    return maybe(key) ?? fallback;
  }

  static String require(String key) {
    final value = maybe(key);
    if (value == null || value.isEmpty) {
      throw StateError(
        'Variável $key ausente. Defina em mobile_v2/.env (veja .env.example).',
      );
    }
    return value;
  }
}
