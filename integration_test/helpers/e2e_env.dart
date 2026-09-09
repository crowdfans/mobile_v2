import 'dart:io' show Platform;

/// Credenciais de uma conta de teste E2E.
class E2eCredentials {
  const E2eCredentials({required this.email, required this.password});

  final String email;
  final String password;
}

/// Variáveis de ambiente para Patrol autenticado (CF-128/129/130).
///
/// Fonte (nessa ordem):
/// 1. `--dart-define=E2E_*=...` / `.patrol.env` (String.fromEnvironment)
/// 2. `Platform.environment` (útil em hosts/CI que injetam env no processo)
///
/// Não lança se faltar — os testes usam [fanSkipReason] / [artistSkipReason].
abstract final class E2eEnv {
  static String? _fromDefine(String key) {
    final raw = switch (key) {
      'E2E_FAN_EMAIL' => const String.fromEnvironment('E2E_FAN_EMAIL'),
      'E2E_FAN_PASSWORD' => const String.fromEnvironment('E2E_FAN_PASSWORD'),
      'E2E_ARTIST_EMAIL' => const String.fromEnvironment('E2E_ARTIST_EMAIL'),
      'E2E_ARTIST_PASSWORD' =>
        const String.fromEnvironment('E2E_ARTIST_PASSWORD'),
      'E2E_ARTIST_UID' => const String.fromEnvironment('E2E_ARTIST_UID'),
      'E2E_FAN_UID' => const String.fromEnvironment('E2E_FAN_UID'),
      'E2E_FAN_HANDLE' => const String.fromEnvironment('E2E_FAN_HANDLE'),
      'E2E_SEED_POST_ID' => const String.fromEnvironment('E2E_SEED_POST_ID'),
      _ => '',
    }.trim();
    return raw.isEmpty ? null : raw;
  }

  static String? _read(String key) {
    final fromDefine = _fromDefine(key);
    if (fromDefine != null) {
      return fromDefine;
    }
    final fromPlatform = Platform.environment[key]?.trim();
    if (fromPlatform != null && fromPlatform.isNotEmpty) {
      return fromPlatform;
    }
    return null;
  }

  static E2eCredentials? get fan {
    final email = _read('E2E_FAN_EMAIL');
    final password = _read('E2E_FAN_PASSWORD');
    if (email == null || password == null) {
      return null;
    }
    return E2eCredentials(email: email, password: password);
  }

  static E2eCredentials? get artist {
    final email = _read('E2E_ARTIST_EMAIL');
    final password = _read('E2E_ARTIST_PASSWORD');
    if (email == null || password == null) {
      return null;
    }
    return E2eCredentials(email: email, password: password);
  }

  static String? get artistUid => _read('E2E_ARTIST_UID');
  static String? get fanUid => _read('E2E_FAN_UID');
  static String? get fanHandle => _read('E2E_FAN_HANDLE');
  static String? get seedPostId => _read('E2E_SEED_POST_ID');

  static bool get hasFan => fan != null;
  static bool get hasArtist => artist != null;

  static const fanMissingMessage =
      'E2E_FAN_EMAIL e E2E_FAN_PASSWORD são obrigatórios. '
      'Copie .env.e2e.example → .env.e2e e passe via '
      '--dart-define / .patrol.env (ver README).';

  static const artistMissingMessage =
      'E2E_ARTIST_EMAIL e E2E_ARTIST_PASSWORD são obrigatórios. '
      'Copie .env.e2e.example → .env.e2e e passe via '
      '--dart-define / .patrol.env (ver README).';

  static String get artistAndFanMissingMessage {
    final missing = <String>[
      if (!hasArtist) 'E2E_ARTIST_EMAIL/PASSWORD',
      if (!hasFan) 'E2E_FAN_EMAIL/PASSWORD',
    ].join(' e ');
    return 'Credenciais ausentes: $missing. '
        'Copie .env.e2e.example → .env.e2e e passe via '
        '--dart-define / .patrol.env (ver README).';
  }
}
