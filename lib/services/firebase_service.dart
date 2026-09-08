import 'package:crowdfans/services/env_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase Auth no projeto `crowdfans-prod`.
///
/// Hoje: opções do `.env` (as mesmas `EXPO_PUBLIC_FIREBASE_*` do Expo).
/// Depois do `flutterfire configure`: trocar para `DefaultFirebaseOptions.currentPlatform`.
abstract final class FirebaseService {
  static FirebaseAuth get auth => FirebaseAuth.instance;

  static Future<void> initialize() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: _fromEnv());
    }
    await auth.setLanguageCode('pt-BR');
  }

  static Future<String?> currentIdToken({bool forceRefresh = false}) async {
    final user = auth.currentUser;
    if (user == null) {
      return null;
    }
    return user.getIdToken(forceRefresh);
  }

  static FirebaseOptions _fromEnv() {
    final appId = EnvService.require('FIREBASE_APP_ID');
    final senderFromAppId = RegExp(r'^1:(\d+):').firstMatch(appId)?.group(1);
    final sender = EnvService.maybe('FIREBASE_MESSAGING_SENDER_ID');
    final messagingSenderId =
        senderFromAppId ??
        sender ??
        EnvService.require('FIREBASE_MESSAGING_SENDER_ID');

    return FirebaseOptions(
      apiKey: EnvService.require('FIREBASE_API_KEY'),
      authDomain: EnvService.require('FIREBASE_AUTH_DOMAIN'),
      projectId: EnvService.require('FIREBASE_PROJECT_ID'),
      storageBucket: EnvService.require('FIREBASE_STORAGE_BUCKET'),
      messagingSenderId: messagingSenderId,
      appId: appId,
    );
  }
}

/// Mensagem de login a partir de erros Firebase/API.
String mapLoginError(Object error) {
  if (error is FirebaseAuthException) {
    return switch (error.code) {
      'invalid-email' => 'Informe um e-mail válido (não o username).',
      'invalid-credential' ||
      'wrong-password' ||
      'user-not-found' ||
      'invalid-login-credentials' => 'E-mail ou senha inválidos.',
      'too-many-requests' =>
        'Muitas tentativas. Aguarde um pouco e tente de novo.',
      'network-request-failed' =>
        'Sem conexão com o Firebase. Verifique a internet.',
      _ => 'Falha no Firebase (${error.code}).',
    };
  }
  final message = error.toString();
  if (RegExp('user not registered', caseSensitive: false).hasMatch(message)) {
    return 'Conta existe no Firebase, mas ainda não está registrada no CrowdFans.';
  }
  if (kDebugMode) {
    return message;
  }
  return 'Não foi possível fazer login.';
}
