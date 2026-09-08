import 'package:crowdfans/services/firebase_phone_auth_service.dart';

/// Facade de OTP SMS (espelho do `OtpService` do Expo).
abstract final class OtpService {
  static Future<void> sendOTP({
    required String countryCode,
    required String phoneNumber,
  }) {
    return FirebasePhoneAuthService.sendPhoneVerificationSMS(
      countryCode,
      phoneNumber,
    );
  }

  static Future<void> resendOTP({
    required String countryCode,
    required String phoneNumber,
  }) {
    return FirebasePhoneAuthService.resendPhoneVerificationSMS(
      countryCode,
      phoneNumber,
    );
  }

  static Future<String> verifyOTP(String otpCode) async {
    final uid = await FirebasePhoneAuthService.verifyOTP(otpCode);
    FirebasePhoneAuthService.clearPhoneVerificationState();
    return uid;
  }

  static String formatPhoneE164(String countryCode, String phoneNumber) {
    return FirebasePhoneAuthService.formatPhoneNumberE164(
      countryCode,
      phoneNumber,
    );
  }
}
