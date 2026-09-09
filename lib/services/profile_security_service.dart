import 'package:crowdfans/api/api_error.dart';
import 'package:crowdfans/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Segurança da conta (reset, troca de senha e e-mail no Firebase).
abstract final class ProfileSecurityService {
  static Future<void> requestPasswordReset(String email) {
    return FirebaseService.auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Reautentica com senha atual e troca a senha Firebase.
  static Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final user = await _reauthenticateWithPassword(currentPassword);
    try {
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (error) {
      throw ApiError(_mapSecurityError(error), 0);
    }
  }

  /// Reautentica e envia o link de confirmação do novo e-mail.
  static Future<void> requestEmailChange(
    String currentPassword,
    String newEmail,
  ) async {
    final user = await _reauthenticateWithPassword(currentPassword);
    try {
      await user.verifyBeforeUpdateEmail(newEmail);
    } on FirebaseAuthException catch (error) {
      throw ApiError(_mapSecurityError(error), 0);
    }
  }

  static Future<User> _reauthenticateWithPassword(
    String currentPassword,
  ) async {
    final user = FirebaseService.auth.currentUser;
    final email = user?.email?.trim();
    if (user == null || email == null || email.isEmpty) {
      throw ApiError(
        'Esta conta não possui autenticação por e-mail e senha.',
        0,
      );
    }
    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      return user;
    } on FirebaseAuthException catch (error) {
      throw ApiError(_mapSecurityError(error), 0);
    }
  }

  static String _mapSecurityError(FirebaseAuthException error) {
    return switch (error.code) {
      'wrong-password' ||
      'invalid-credential' ||
      'invalid-login-credentials' => 'Senha atual incorreta.',
      'weak-password' => 'A nova senha é fraca demais.',
      'email-already-in-use' => 'Este e-mail já está em uso.',
      'requires-recent-login' =>
        'Faça login de novo antes de alterar a segurança.',
      'too-many-requests' =>
        'Muitas tentativas. Aguarde um pouco e tente de novo.',
      _ => 'Não foi possível atualizar a segurança (${error.code}).',
    };
  }
}
