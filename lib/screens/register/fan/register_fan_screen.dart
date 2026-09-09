import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/register/register_fan_scaffold.dart';
import 'package:crowdfans/components/register/register_phone_field.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/otp_service.dart';
import 'package:crowdfans/state/fan_register_store.dart';
import 'package:crowdfans/utils/phone_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Entrada do telefone no cadastro Superfã.
class RegisterFanScreen extends ConsumerStatefulWidget {
  const RegisterFanScreen({super.key});

  @override
  ConsumerState<RegisterFanScreen> createState() => _RegisterFanScreenState();
}

class _RegisterFanScreenState extends ConsumerState<RegisterFanScreen> {
  late final TextEditingController _phone;
  String _error = '';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _phone = TextEditingController();
  }

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> handleNext() async {
    final form = ref.read(fanRegisterProvider);
    if (!isPhonePartsValid(form.phoneCountryCode, form.phone)) {
      return;
    }
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      await OtpService.sendOTP(
        countryCode: form.phoneCountryCode,
        phoneNumber: form.phone,
      );
      if (mounted) {
        context.push(Pages.registerFanOtp);
      }
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final form = ref.watch(fanRegisterProvider);
    final valid = isPhonePartsValid(form.phoneCountryCode, form.phone);

    return RegisterFanScaffold(
      onBack: () => context.go(Pages.loginFan),
      footer: AppButton(
        key: const Key('register-phone-submit'),
        label: 'Cadastrar Telefone',
        onPressed: handleNext,
        disabled: !valid,
        loading: _loading,
      ),
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          const SizedBox(height: 40),
          Text(
            'Cadastrar',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AuthAccentPalette.fan.start,
            ),
          ),
          Text(
            'Fan',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 44,
              height: 50 / 44,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 40),
          RegisterPhoneField(
            controller: _phone,
            onDigitsChanged: (digits) {
              ref
                  .read(fanRegisterProvider.notifier)
                  .setFields(
                    (current) => current.copyWith(
                      phone: digits,
                      phoneVerified: false,
                      firebaseUid: '',
                    ),
                  );
            },
          ),
          if (_error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                key: const Key('register-phone-error'),
                _error,
                style: TextStyle(color: colors.danger),
              ),
            ),
        ],
      ),
    );
  }
}
