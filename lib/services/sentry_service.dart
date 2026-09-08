import 'package:crowdfans/services/env_service.dart';
import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Observabilidade — mesmo contrato do Expo (`initSentry` só se houver DSN).
abstract final class SentryService {
  static String? get _dsn => EnvService.maybe('SENTRY_DSN');

  static bool get isEnabled {
    final dsn = _dsn;
    return dsn != null && dsn.isNotEmpty;
  }

  /// Inicializa o Sentry. Sem DSN, não faz nada (igual ao Expo).
  static Future<void> initialize() async {
    if (!isEnabled) {
      return;
    }
    await SentryFlutter.init((options) {
      options.dsn = _dsn;
      options.environment = EnvService.get('ENV', 'development');
      options.tracesSampleRate = kReleaseMode ? 0.2 : 0;
    });
  }

  static Future<void> captureException(
    Object error, [
    StackTrace? stack,
  ]) async {
    if (!isEnabled) {
      return;
    }
    await Sentry.captureException(error, stackTrace: stack);
  }
}
