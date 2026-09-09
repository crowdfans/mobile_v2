import 'package:crowdfans/firebase_options.dart';
import 'package:crowdfans/services/api_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase Auth no projeto `crowdfans-prod` (`DefaultFirebaseOptions`).
abstract final class FirebaseService {
  static FirebaseAuth get auth => FirebaseAuth.instance;

  static Future<void> initialize() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
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
  if (RegExp(
    'Falha de rede|Tempo de resposta|Failed to fetch|Network request failed|SocketException|ClientException',
    caseSensitive: false,
  ).hasMatch(message)) {
    final debug = apiConfigDebug();
    return 'API inacessível (${debug.mode}): ${debug.baseUrl}\n$message';
  }
  if (kDebugMode) {
    return message;
  }
  return 'Não foi possível fazer login.';
}
