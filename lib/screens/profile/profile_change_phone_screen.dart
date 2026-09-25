import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/input/app_text_field.dart';
import 'package:crowdfans/components/profile/account_feedback_banner.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/services/firebase_service.dart';
import 'package:crowdfans/services/profile_security_service.dart';
import 'package:crowdfans/utils/phone_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Trocar telefone de recuperação (CF-217).
class ProfileChangePhoneScreen extends StatefulWidget {
  const ProfileChangePhoneScreen({super.key});

  @override
  State<ProfileChangePhoneScreen> createState() =>
      _ProfileChangePhoneScreenState();
}

class _ProfileChangePhoneScreenState extends State<ProfileChangePhoneScreen> {
  final _phoneController = TextEditingController();
  var _currentPassword = '';
  var _phoneDigits = '';
  var _otp = '';
  var _awaitingOtp = false;
  var _submitting = false;
  var _formNonce = 0;
  String? _error;
  String? _success;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String get _currentPhoneLabel {
    final raw = FirebaseService.auth.currentUser?.phoneNumber?.trim() ?? '';
    if (raw.isEmpty) {
      if (kUseCfTempMocks && CfTempMocks.useSecuritySettingsFixtures) {
        return Cf217ChangePhoneMock.currentPhoneLabel;
      }
      return 'não informado';
    }
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 12 && digits.startsWith('55')) {
      return formatPhoneNumber(digits.substring(2));
    }
    if (digits.length >= 10) {
      return formatPhoneNumber(
        digits.length > 11 ? digits.substring(digits.length - 11) : digits,
      );
    }
    return raw;
  }

  bool get _canContinue {
    if (_awaitingOtp) {
      return _otp.trim().length >= 6 && !_submitting;
    }
    return _currentPassword.length >= 6 &&
        isPhonePartsValid('55', _phoneDigits) &&
        !_submitting;
  }

  void handlePhoneChanged(String value) {
    final digits = sanitizePhoneNumber(value);
    final formatted = formatPhoneNumber(digits);
    if (_phoneController.text != formatted) {
      _phoneController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    setState(() {
      _phoneDigits = digits;
      _error = null;
      _success = null;
    });
  }

  Future<void> handleContinue() async {
    if (!_canContinue) {
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
      _success = null;
    });
    try {
      if (_awaitingOtp) {
        await ProfileSecurityService.confirmPhoneChange(_otp);
        if (!mounted) {
          return;
        }
        setState(() {
          _awaitingOtp = false;
          _otp = '';
          _currentPassword = '';
          _phoneDigits = '';
          _phoneController.clear();
          _formNonce++;
          _success =
              'Telefone confirmado. O novo número já está vinculado à conta.';
        });
      } else {
        await ProfileSecurityService.requestPhoneChange(
          _currentPassword,
          '55',
          _phoneDigits,
        );
        if (!mounted) {
          return;
        }
        setState(() {
          _awaitingOtp = true;
          _success =
              'Enviamos um SMS. O novo telefone só será confirmado após o código.';
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() => _error = error.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            ProfileScreenHeader(
              title: 'Trocar telefone',
              onBack: () => context.pop(),
            ),
            Expanded(
              child: ListView(
                key: ValueKey(_formNonce),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  Text(
                    'Atualize o telefone de recuperação',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Usaremos esse número para OTPs, confirmação de login e '
                    'recuperação de acesso quando necessário.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Telefone atual: $_currentPhoneLabel',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (!_awaitingOtp) ...[
                    AppTextField(
                      key: ValueKey('pw-$_formNonce'),
                      label: 'Senha atual',
                      hint: 'Digite sua senha atual',
                      obscureText: true,
                      onChanged: (value) {
                        setState(() {
                          _currentPassword = value;
                          _error = null;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      key: ValueKey('phone-$_formNonce'),
                      label: 'Novo telefone',
                      hint: '(11) 99999-9999',
                      keyboardType: TextInputType.phone,
                      initialValue: _phoneController.text,
                      onChanged: handlePhoneChanged,
                    ),
                  ] else ...[
                    AppTextField(
                      key: ValueKey('otp-$_formNonce'),
                      label: 'Código SMS',
                      hint: '6 dígitos',
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          _otp = value;
                          _error = null;
                        });
                      },
                    ),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    AccountFeedbackBanner(message: _error!, success: false),
                  ],
                  if (_success != null) ...[
                    const SizedBox(height: 16),
                    AccountFeedbackBanner(message: _success!, success: true),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: AppButton(
                label: _submitting
                    ? 'Aguarde...'
                    : _awaitingOtp
                    ? 'Confirmar telefone'
                    : 'Continuar',
                disabled: !_canContinue,
                onPressed: handleContinue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
