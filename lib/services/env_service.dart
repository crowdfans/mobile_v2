import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Leitura de `.env` (aceita chaves Expo `EXPO_PUBLIC_*` e as curtas do Flutter).

abstract final class EnvService {
  static const _expoPrefix = 'EXPO_PUBLIC_';

  /// Carrega env do flavor/backend ativo, depois `.env` / `.env.example`.
  ///
  /// Ordem: `.env.<flavor>` → `.env` → `.env.<flavor>.example` → `.env.example`.
  /// Flavor via `--dart-define=APP_FLAVOR=` (default `gcp` na linha `release/0.2`).
  static Future<void> load() async {
    const flavorDefine = String.fromEnvironment(
      'APP_FLAVOR',
      defaultValue: 'gcp',
    );
    final flavor = flavorDefine.trim().toLowerCase();
    final candidates = <String>[
      if (flavor.isNotEmpty) '.env.$flavor',
      '.env',
      if (flavor.isNotEmpty) '.env.$flavor.example',
      '.env.example',
    ];

    Object? lastError;
    for (final name in candidates) {
      try {
        await dotenv.load(fileName: name);
        return;
      } catch (error) {
        lastError = error;
      }
    }
    throw StateError(
      'Não foi possível carregar env (flavor=$flavor): $lastError',
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
