import 'package:crowdfans/api/api_urls.dart';
import 'package:crowdfans/services/http_service.dart';

/// Login/registro no backend Go a partir do token Firebase.
abstract final class AuthService {
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
