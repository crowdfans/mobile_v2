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
        label: 'Cadastrar Telefone',
        onPressed: handleNext,
        disabled: !valid,
        loading: _loading,
      ),
      child: ListView(
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
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 40),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            onChanged: (value) {
              final digits = sanitizePhoneNumber(value);
              final formatted = formatPhoneNumber(digits);
              if (formatted != _phone.text) {
                _phone.value = TextEditingValue(
                  text: formatted,
                  selection: TextSelection.collapsed(offset: formatted.length),
                );
              }
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
            decoration: InputDecoration(
              hintText: '(11) 91234-5678',
              hintStyle: TextStyle(color: colors.textTertiary),
              filled: true,
              fillColor: colors.inputBackground,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colors.inputBorder),
              ),
            ),
            style: TextStyle(color: colors.textPrimary, fontSize: 16),
          ),
          if (_error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(_error, style: TextStyle(color: colors.danger)),
            ),
        ],
      ),
    );
  }
}
