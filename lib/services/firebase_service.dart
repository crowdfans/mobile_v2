import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Firebase Auth (mesmo projeto `crowdfans-dev` do Expo).
abstract final class FirebaseService {
  static FirebaseAuth get auth => FirebaseAuth.instance;

  static Future<void> initialize() async {
    final options = FirebaseOptions(
      apiKey: _env(
        'FIREBASE_API_KEY',
        'AIzaSyDcIz2sZ2S7uf6bJm-uC0eNlYlnorFEyv4',
      ),
      authDomain: _env(
        'FIREBASE_AUTH_DOMAIN',
        'crowdfans-dev-e9703.firebaseapp.com',
      ),
      projectId: _env('FIREBASE_PROJECT_ID', 'crowdfans-dev-e9703'),
      storageBucket: _env(
        'FIREBASE_STORAGE_BUCKET',
        'crowdfans-dev-e9703.firebasestorage.app',
      ),
      messagingSenderId: _env(
        'FIREBASE_MESSAGING_SENDER_ID',
        '831877043516',
      ),
      appId: _env(
        'FIREBASE_APP_ID',
        '1:831877043516:web:ff725e9f6c5b0a5a2a7a39',
      ),
    );

    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: options);
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

  static String _env(String key, String fallback) {
    final value = dotenv.maybeGet(key)?.trim();
    if (value == null || value.isEmpty) {
      return fallback;
    }
    return value;
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
      'invalid-login-credentials' =>
        'E-mail ou senha inválidos.',
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
