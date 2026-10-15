// Seleciona FirebaseOptions por APP_FLAVOR (gcp | digitalocean).
// Stubs sem segredos — ver firebase_options_gcp.dart / _digitalocean.dart.
// Chaves reais: `.env` / `--dart-define` (não commitadas).
// ignore_for_file: type=lint
import 'package:crowdfans/firebase_options_digitalocean.dart';
import 'package:crowdfans/firebase_options_gcp.dart';
import 'package:crowdfans/services/api_config.dart';
import 'package:crowdfans/services/env_service.dart';
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// [FirebaseOptions] do flavor ativo (`APP_FLAVOR` / default `gcp`).
///
/// Stubs `REPLACE_ME_*` ficam no git. Se `.env` ou `--dart-define` trouxer
/// `FIREBASE_API_KEY` (ou `FIREBASE_<PLATAFORMA>_API_KEY`), esse valor
/// substitui o stub na inicialização.
///
/// Example:
/// ```dart
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    final stub = switch (appFlavor()) {
      'digitalocean' || 'do' => DigitalOceanFirebaseOptions.currentPlatform,
      _ => GcpFirebaseOptions.currentPlatform,
    };
    return _overlayEnv(stub);
  }

  static FirebaseOptions _overlayEnv(FirebaseOptions stub) {
    final apiKey = _platformValue('API_KEY');
    if (apiKey == null || apiKey.contains('REPLACE_ME')) {
      return stub;
    }
    final appId = _platformValue('APP_ID');
    final sender = _value('FIREBASE_MESSAGING_SENDER_ID');
    final projectId = _value('FIREBASE_PROJECT_ID');
    final authDomain = _value('FIREBASE_AUTH_DOMAIN');
    final bucket = _value('FIREBASE_STORAGE_BUCKET');
    final measurementId = _value('FIREBASE_MEASUREMENT_ID');
    return FirebaseOptions(
      apiKey: apiKey,
      appId: (appId == null || appId.contains('REPLACE_ME'))
          ? stub.appId
          : appId,
      messagingSenderId: sender ?? stub.messagingSenderId,
      projectId: projectId ?? stub.projectId,
      authDomain: authDomain ?? stub.authDomain,
      storageBucket: bucket ?? stub.storageBucket,
      measurementId: measurementId ?? stub.measurementId,
      iosBundleId: stub.iosBundleId,
    );
  }

  /// `FIREBASE_ANDROID_*` / `FIREBASE_IOS_*` / `FIREBASE_WEB_*`.
  /// No web, `FIREBASE_API_KEY` e `FIREBASE_APP_ID` (schema do Expo) também valem.
  static String? _platformValue(String field) {
    final platform = _platformTag();
    final specific = _value('FIREBASE_${platform}_$field');
    if (specific != null) {
      return specific;
    }
    if (platform == 'WEB') {
      return _value('FIREBASE_$field');
    }
    return null;
  }

  static String _platformTag() {
    if (kIsWeb) {
      return 'WEB';
    }
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'ANDROID',
      TargetPlatform.iOS => 'IOS',
      _ => 'WEB',
    };
  }

  static String? _value(String key) {
    final fromDefine = _fromDefine(key);
    if (fromDefine.isNotEmpty) {
      return fromDefine;
    }
    try {
      if (!dotenv.isInitialized) {
        return null;
      }
    } catch (_) {
      return null;
    }
    final fromEnv = EnvService.maybe(key);
    if (fromEnv == null || fromEnv.isEmpty) {
      return null;
    }
    return fromEnv;
  }

  static String _fromDefine(String key) {
    final raw = switch (key) {
      'FIREBASE_API_KEY' => const String.fromEnvironment('FIREBASE_API_KEY'),
      'FIREBASE_APP_ID' => const String.fromEnvironment('FIREBASE_APP_ID'),
      'FIREBASE_WEB_API_KEY' =>
        const String.fromEnvironment('FIREBASE_WEB_API_KEY'),
      'FIREBASE_WEB_APP_ID' =>
        const String.fromEnvironment('FIREBASE_WEB_APP_ID'),
      'FIREBASE_ANDROID_API_KEY' =>
        const String.fromEnvironment('FIREBASE_ANDROID_API_KEY'),
      'FIREBASE_ANDROID_APP_ID' =>
        const String.fromEnvironment('FIREBASE_ANDROID_APP_ID'),
      'FIREBASE_IOS_API_KEY' =>
        const String.fromEnvironment('FIREBASE_IOS_API_KEY'),
      'FIREBASE_IOS_APP_ID' =>
        const String.fromEnvironment('FIREBASE_IOS_APP_ID'),
      'FIREBASE_MESSAGING_SENDER_ID' =>
        const String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
      'FIREBASE_PROJECT_ID' =>
        const String.fromEnvironment('FIREBASE_PROJECT_ID'),
      'FIREBASE_AUTH_DOMAIN' =>
        const String.fromEnvironment('FIREBASE_AUTH_DOMAIN'),
      'FIREBASE_STORAGE_BUCKET' =>
        const String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
      'FIREBASE_MEASUREMENT_ID' =>
        const String.fromEnvironment('FIREBASE_MEASUREMENT_ID'),
      _ => '',
    };
    return raw.trim();
  }

  /// Qual arquivo stub está ativo (debug / testes).
  static String get activeStubName {
    switch (appFlavor()) {
      case 'digitalocean':
      case 'do':
        return 'digitalocean';
      default:
        return 'gcp';
    }
  }
}
