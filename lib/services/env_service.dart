import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Leitura de `.env` (aceita chaves Expo `EXPO_PUBLIC_*` e as curtas do Flutter).

abstract final class EnvService {
  static const _expoPrefix = 'EXPO_PUBLIC_';

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
    for (final name in _aliases(key)) {
      final value = dotenv.maybeGet(name)?.trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
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
        'Variável $key ausente. Copie o .env do Expo (prod) para mobile_v2/.env.',
      );
    }
    return value;
  }

  static List<String> _aliases(String key) {
    if (key.startsWith(_expoPrefix)) {
      return [key, key.substring(_expoPrefix.length)];
    }
    return [key, '$_expoPrefix$key'];
  }
}
