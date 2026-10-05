import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/input/app_text_field.dart';
import 'package:crowdfans/components/profile/account_feedback_banner.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/firebase_service.dart';
import 'package:crowdfans/services/profile_security_service.dart';
import 'package:crowdfans/services/profile_service.dart';
import 'package:crowdfans/utils/phone_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Trocar telefone — página dedicada (CF-217). Layout = print YouTrack.
/// Sem abas / sem hub Segurança e login embutido.
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
  String _backendPhone = '';

  @override
  void initState() {
    super.initState();
    handleLoadBackendPhone();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> handleLoadBackendPhone() async {
    try {
      final profile = await ProfileService.getMyProfile();
      if (!mounted) {
        return;
      }
      setState(() => _backendPhone = profile.phone.trim());
    } catch (_) {
      // Firebase / backend permanecem como fallback de exibição.
    }
  }

  String get _currentPhoneLabel {
    String raw = '';
    try {
      raw = FirebaseService.auth.currentUser?.phoneNumber?.trim() ?? '';
    } catch (_) {
      // Testes / Firebase ainda não inicializado.
    }
    final source = raw.isNotEmpty ? raw : _backendPhone;
    if (source.isEmpty) {
      return 'não informado';
    }
    final digits = source.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 12 && digits.startsWith('55')) {
      return formatPhoneNumber(digits.substring(2));
    }
    if (digits.length >= 10) {
      return formatPhoneNumber(
        digits.length > 11 ? digits.substring(digits.length - 11) : digits,
      );
    }
    return source;
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
        String e164 = '';
        try {
          e164 = FirebaseService.auth.currentUser?.phoneNumber?.trim() ?? '';
        } catch (_) {}
        setState(() {
          _awaitingOtp = false;
          _otp = '';
          _currentPassword = '';
          _phoneDigits = '';
          _phoneController.clear();
          _formNonce++;
          if (e164.isNotEmpty) {
            _backendPhone = e164;
          }
          _success =
              'Telefone confirmado. O novo número já está vinculado à conta.';
        });
        await handleLoadBackendPhone();
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
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: ListView(
                  key: ValueKey(_formNonce),
                  // Espaçamento generoso = REFERÊNCIA CF-217 (não o hub).
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  children: [
                    Text(
                      'Atualize o telefone de recuperação',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Usaremos esse número para OTPs, confirmação de login e '
                      'recuperação de acesso quando necessário.',
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.45,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Telefone atual: $_currentPhoneLabel',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (!_awaitingOtp) ...[
                      AppTextField(
                        key: ValueKey('pw-$_formNonce'),
                        label: 'Senha atual',
                        hint: 'Digite sua senha atual',
                        obscureText: true,
                        // Print CF-217: campo sem ícone de olho.
                        showObscureToggle: false,
                        onChanged: (value) {
                          setState(() {
                            _currentPassword = value;
                            _error = null;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
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
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
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
