import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/register/register_fan_scaffold.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/otp_service.dart';
import 'package:crowdfans/state/fan_register_store.dart';
import 'package:crowdfans/utils/phone_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Confirmação do código SMS.
class RegisterFanOtpScreen extends ConsumerStatefulWidget {
  const RegisterFanOtpScreen({super.key});

  @override
  ConsumerState<RegisterFanOtpScreen> createState() =>
      _RegisterFanOtpScreenState();
}

class _RegisterFanOtpScreenState extends ConsumerState<RegisterFanOtpScreen> {
  String _code = '';
  String _error = '';
  bool _verifying = false;
  bool _resending = false;

  Future<void> handleVerify() async {
    setState(() {
      _verifying = true;
      _error = '';
    });
    try {
      final uid = await OtpService.verifyOTP(_code);
      ref
          .read(fanRegisterProvider.notifier)
          .setFields(
            (current) =>
                current.copyWith(phoneVerified: true, firebaseUid: uid),
          );
      if (mounted) {
        context.push(Pages.registerFanEmail);
      }
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      if (mounted) {
        setState(() => _verifying = false);
      }
    }
  }

  Future<void> handleResend() async {
    final form = ref.read(fanRegisterProvider);
    setState(() => _resending = true);
    try {
      await OtpService.resendOTP(
        countryCode: form.phoneCountryCode,
        phoneNumber: form.phone,
      );
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      if (mounted) {
        setState(() => _resending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final form = ref.watch(fanRegisterProvider);
    final phone = formatPhoneDisplay(form.phoneCountryCode, form.phone);

    return RegisterFanScaffold(
      onBack: () => context.pop(),
      footer: AppButton(
        label: 'Validar codigo',
        onPressed: handleVerify,
        disabled: _code.length != 6,
        loading: _verifying,
      ),
      child: ListView(
        children: [
          const SizedBox(height: 32),
          Text(
            'Confirme o seu telefone',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Digite o codigo de 6 numeros enviado para $phone.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: colors.textSecondary),
          ),
          const SizedBox(height: 36),
          TextField(
            keyboardType: TextInputType.number,
            maxLength: 6,
            onChanged: (value) => setState(() => _code = value.trim()),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 12,
              color: colors.textPrimary,
            ),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: colors.inputBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          if (_error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                _error,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.danger),
              ),
            ),
          TextButton(
            onPressed: _resending ? null : handleResend,
            child: Text(_resending ? 'Reenviando...' : 'Reenviar codigo'),
          ),
        ],
      ),
    );
  }
}
