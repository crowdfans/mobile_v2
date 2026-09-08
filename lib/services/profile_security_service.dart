import 'package:crowdfans/services/firebase_service.dart';

/// Segurança da conta (reset de senha Firebase).
abstract final class ProfileSecurityService {
  static Future<void> requestPasswordReset(String email) {
    return FirebaseService.auth.sendPasswordResetEmail(email: email.trim());
  }
}
