import 'package:crowdfans/api/api_urls.dart';
import 'package:crowdfans/services/http_service.dart';

/// Login/registro no backend Go a partir do token Firebase.
///
/// Fluxo gcp (`release/0.2`): Firebase Auth (mesmo projeto) → ID token →
/// `POST /auth/login` / register **sem** Bearer prévio (`requireAuth: false`).
/// Chamadas autenticadas seguintes usam [HttpService] + Bearer.
/// Upload de mídia: Bearer só no presign; PUT GCS via [ObjectStorageClient].
abstract final class AuthService {
  static Future<void> registerFan({
    required String email,
    required String token,
    String? displayName,
    String? phone,
    bool phoneVerified = false,
  }) async {
    await HttpService.request<dynamic>(
      ApiUrls.registerFan,
      method: Method.post,
      body: {
        'email': email,
        'token': token,
        'displayName': ?displayName,
        'phone': ?phone,
        'phoneVerified': phoneVerified,
      },
      requireAuth: false,
    );
  }

  static Future<void> loginBackendWithFirebaseToken(String idToken) async {
    await HttpService.request<dynamic>(
      ApiUrls.authLogin,
      method: Method.post,
      body: {'token': idToken},
      requireAuth: false,
    );
  }

  static Future<void> verifyBackendFirebaseToken(String idToken) async {
    await HttpService.request<dynamic>(
      ApiUrls.authLoginVerifyToken,
      method: Method.post,
      body: {'token': idToken},
      requireAuth: false,
    );
  }
}
