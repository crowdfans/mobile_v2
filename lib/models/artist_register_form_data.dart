import 'package:crowdfans/models/artist_verification_platform.dart';
import 'package:crowdfans/models/artist_verification_status.dart';

/// Campos do cadastro de artista usados nas telas atuais do Expo.
///
/// Spotify, contestação de nome e consentimento parental existem no modelo
/// legado, mas as telas estão ⛔ — não entram neste DTO até o Expo ligar.
class ArtistRegisterFormData {
  const ArtistRegisterFormData({
    this.role = 'artist',
    this.phoneCountryCode = '+55',
    this.phone = '',
    this.phoneVerified = false,
    this.firebaseUid = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.name = '',
    this.username = '',
    this.artistVerificationStatus = ArtistVerificationStatus.idle,
    this.artistVerificationPlatform,
    this.artistVerificationHandle = '',
    this.artistVerificationError = '',
  });

  final String role;
  final String phoneCountryCode;
  final String phone;
  final bool phoneVerified;
  final String firebaseUid;
  final String email;
  final String password;
  final String confirmPassword;
  final String name;
  final String username;
  final ArtistVerificationStatus artistVerificationStatus;
  final ArtistVerificationPlatform? artistVerificationPlatform;
  final String artistVerificationHandle;
  final String artistVerificationError;

  ArtistRegisterFormData copyWith({
    String? role,
    String? phoneCountryCode,
    String? phone,
    bool? phoneVerified,
    String? firebaseUid,
    String? email,
    String? password,
    String? confirmPassword,
    String? name,
    String? username,
    ArtistVerificationStatus? artistVerificationStatus,
    ArtistVerificationPlatform? artistVerificationPlatform,
    String? artistVerificationHandle,
    String? artistVerificationError,
  }) {
    return ArtistRegisterFormData(
      role: role ?? this.role,
      phoneCountryCode: phoneCountryCode ?? this.phoneCountryCode,
      phone: phone ?? this.phone,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      name: name ?? this.name,
      username: username ?? this.username,
      artistVerificationStatus:
          artistVerificationStatus ?? this.artistVerificationStatus,
      artistVerificationPlatform:
          artistVerificationPlatform ?? this.artistVerificationPlatform,
      artistVerificationHandle:
          artistVerificationHandle ?? this.artistVerificationHandle,
      artistVerificationError:
          artistVerificationError ?? this.artistVerificationError,
    );
  }
}
