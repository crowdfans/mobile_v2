// Stub FlutterFire options — flavor `digitalocean` (comparar com DO / prod).
// Sem segredos: preencher com valores do app crowdfans-prod (nunca commitar keys).
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// [FirebaseOptions] stub para builds que apontam o backend DigitalOcean.
///
/// Firebase continua em `crowdfans-prod`. Keys reais só em cópia local /
/// CI secret — não neste arquivo.
abstract final class DigitalOceanFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DigitalOceanFirebaseOptions: plataforma não configurada '
          '(${defaultTargetPlatform.name}).',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REPLACE_ME_FIREBASE_WEB_API_KEY',
    appId: '1:000000000000:web:replace_me_digitalocean',
    messagingSenderId: '000000000000',
    projectId: 'crowdfans-prod',
    authDomain: 'crowdfans-prod.firebaseapp.com',
    storageBucket: 'crowdfans-prod.firebasestorage.app',
    measurementId: 'G-REPLACE_ME',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_ME_FIREBASE_ANDROID_API_KEY',
    appId: '1:000000000000:android:replace_me_digitalocean',
    messagingSenderId: '000000000000',
    projectId: 'crowdfans-prod',
    storageBucket: 'crowdfans-prod.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_ME_FIREBASE_IOS_API_KEY',
    appId: '1:000000000000:ios:replace_me_digitalocean',
    messagingSenderId: '000000000000',
    projectId: 'crowdfans-prod',
    storageBucket: 'crowdfans-prod.firebasestorage.app',
    iosBundleId: 'com.crowdfans.crowdfans',
  );
}
