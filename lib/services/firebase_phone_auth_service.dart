import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Phone Auth Firebase (SMS). Na web exige reCAPTCHA — ver `PENDENCIA.md`.
abstract final class FirebasePhoneAuthService {
  static String? _verificationId;

  static String formatPhoneNumberE164(String countryCode, String phoneNumber) {
    final cc = countryCode.replaceAll(RegExp(r'\D'), '');
    final local = phoneNumber.replaceAll(RegExp(r'\D'), '');
    return '+$cc$local';
  }

  static Future<void> sendPhoneVerificationSMS(
    String countryCode,
    String phoneNumber,
  ) {
    return _verify(countryCode, phoneNumber);
  }

  static Future<void> resendPhoneVerificationSMS(
    String countryCode,
    String phoneNumber,
  ) {
    return _verify(countryCode, phoneNumber);
  }

  static Future<void> _verify(String countryCode, String phoneNumber) async {
    if (kIsWeb) {
      throw StateError(
        'OTP na web precisa de reCAPTCHA. Use o app iOS/Android por enquanto.',
      );
    }
    final completer = Completer<void>();
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: formatPhoneNumberE164(countryCode, phoneNumber),
      timeout: const Duration(seconds: 60),
      verificationCompleted: (_) {},
      verificationFailed: (error) {
        if (!completer.isCompleted) {
          completer.completeError(error);
        }
      },
      codeSent: (verificationId, _) {
        _verificationId = verificationId;
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
      codeAutoRetrievalTimeout: (verificationId) {
        _verificationId = verificationId;
      },
    );
    await completer.future;
  }

  static Future<String> verifyOTP(String otpCode) async {
    final id = _verificationId;
    if (id == null || id.isEmpty) {
      throw StateError('Reenvie o SMS antes de validar o código.');
    }
    final credential = PhoneAuthProvider.credential(
      verificationId: id,
      smsCode: otpCode,
    );
    final result = await FirebaseAuth.instance.signInWithCredential(credential);
    final uid = result.user?.uid;
    if (uid == null) {
      throw StateError('Não foi possível validar o telefone.');
    }
    return uid;
  }

  static void clearPhoneVerificationState() {
    _verificationId = null;
  }
}
