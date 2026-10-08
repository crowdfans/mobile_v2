// Seleciona FirebaseOptions por APP_FLAVOR (gcp | digitalocean).
// Stubs sem segredos — ver firebase_options_gcp.dart / _digitalocean.dart.
// ignore_for_file: type=lint
import 'package:crowdfans/firebase_options_digitalocean.dart';
import 'package:crowdfans/firebase_options_gcp.dart';
import 'package:crowdfans/services/api_config.dart';
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

/// [FirebaseOptions] do flavor ativo (`APP_FLAVOR` / default `gcp`).
///
/// Example:
/// ```dart
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (appFlavor()) {
      case 'digitalocean':
      case 'do':
        return DigitalOceanFirebaseOptions.currentPlatform;
      case 'gcp':
      case 'local': // local usa flavor Android gcp + mesmas options GCP
      default:
        return GcpFirebaseOptions.currentPlatform;
    }
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
