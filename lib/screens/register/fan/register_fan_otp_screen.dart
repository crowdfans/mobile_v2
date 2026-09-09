import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/register/otp_code_field.dart';
import 'package:crowdfans/components/register/register_fan_scaffold.dart';
import 'package:crowdfans/components/register/register_step_header.dart';
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
  String _resent = '';
  bool _verifying = false;
  bool _resending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final form = ref.read(fanRegisterProvider);
      if (!isPhonePartsValid(form.phoneCountryCode, form.phone) && mounted) {
        context.go(Pages.registerFan);
      }
    });
  }

  Future<void> handleVerify() async {
    setState(() {
      _verifying = true;
      _error = '';
      _resent = '';
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
    setState(() {
      _resending = true;
      _code = '';
      _error = '';
      _resent = 'Enviando novo código...';
    });
    try {
      await OtpService.resendOTP(
        countryCode: form.phoneCountryCode,
        phoneNumber: form.phone,
      );
      setState(() => _resent = 'Enviamos um novo código para o seu telefone.');
    } catch (error) {
      setState(() {
        _resent = '';
        _error = error.toString();
      });
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
      toolbarTitle: 'Verificação',
      onBack: () => context.pop(),
      footer: AppButton(
        key: const Key('register-otp-submit'),
        label: 'Validar código',
        onPressed: handleVerify,
        disabled: _code.length != 6,
        loading: _verifying,
      ),
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          RegisterStepHeader(
            title: 'Confirme o seu telefone',
            subtitle: 'Digite o código de 6 números enviado para $phone.',
          ),
          const SizedBox(height: 36),
          OtpCodeField(
            code: _code,
            onChanged: (value) => setState(() {
              _code = value;
              _error = '';
              _resent = '';
            }),
          ),
          if (_error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                key: const Key('register-otp-error'),
                _error,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: colors.danger),
              ),
            ),
          if (_resent.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                _resent,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: colors.success),
              ),
            ),
          TextButton(
            onPressed: _resending ? null : handleResend,
            child: Text(
              _resending ? 'Reenviando...' : 'Reenviar código',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: colors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
