import 'package:crowdfans/api/api_urls.dart';
import 'package:crowdfans/models/profile.dart';
import 'package:crowdfans/services/http_service.dart';

/// Perfil do usuário autenticado.
abstract final class ProfileService {
  static Future<Profile> getMyProfile() {
    return HttpService.request<Profile>(
      ApiUrls.profile,
      parse: (json) => Profile.fromJson(json! as Map<String, dynamic>),
    );
  }
}
