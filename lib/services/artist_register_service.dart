import 'package:crowdfans/api/api_urls.dart';
import 'package:crowdfans/services/auth_service.dart';
import 'package:crowdfans/services/firebase_service.dart';
import 'package:crowdfans/services/http_service.dart';

/// Cadastro de artista: Firebase Auth + `POST /register/artist`.
abstract final class ArtistRegisterService {
  /// Cria o user no Firebase, registra no backend e valida a sessão.
  static Future<void> registerArtist({
    required String email,
    required String password,
    required String displayName,
    String? phone,
    bool phoneVerified = false,
  }) async {
    if (FirebaseService.auth.currentUser != null) {
      await FirebaseService.auth.signOut();
    }

    final credential = await FirebaseService.auth
        .createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
    final trimmedName = displayName.trim();
    if (trimmedName.isNotEmpty) {
      await credential.user?.updateDisplayName(trimmedName);
    }
    final idToken = await credential.user?.getIdToken(true);
    if (idToken == null) {
      throw StateError('token vazio');
    }

    await HttpService.request<dynamic>(
      ApiUrls.registerArtist,
      method: Method.post,
      body: {
        'email': email.trim(),
        'token': idToken,
        'displayName': trimmedName,
        'phone': ?phone,
        'phoneVerified': phoneVerified,
      },
      requireAuth: false,
    );

    await AuthService.loginBackendWithFirebaseToken(idToken);
    await AuthService.verifyBackendFirebaseToken(idToken);
  }
}
