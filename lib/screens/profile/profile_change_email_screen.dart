import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/input/app_text_field.dart';
import 'package:crowdfans/components/profile/account_feedback_banner.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/firebase_service.dart';
import 'package:crowdfans/services/profile_security_service.dart';
import 'package:crowdfans/utils/email_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Trocar e-mail — página dedicada (CF-165). Layout = print YouTrack.
class ProfileChangeEmailScreen extends StatefulWidget {
  const ProfileChangeEmailScreen({super.key});

  @override
  State<ProfileChangeEmailScreen> createState() =>
      _ProfileChangeEmailScreenState();
}

class _ProfileChangeEmailScreenState extends State<ProfileChangeEmailScreen> {
  var _currentPassword = '';
  var _newEmail = '';
  var _confirmEmail = '';
  var _submitting = false;
  var _formNonce = 0;
  String? _error;
  String? _success;

  String get _currentEmail {
    try {
      return FirebaseService.auth.currentUser?.email ?? '';
    } catch (_) {
      // Testes / Firebase ainda não inicializado.
      return '';
    }
  }

  bool get _formReady {
    final normalized = _newEmail.trim().toLowerCase();
    if (_currentPassword.length < 6) {
      return false;
    }
    if (!isEmailValid(normalized)) {
      return false;
    }
    if (normalized != _confirmEmail.trim().toLowerCase()) {
      return false;
    }
    return normalized != _currentEmail.toLowerCase();
  }

  String? validateEmail() {
    final normalized = _newEmail.trim().toLowerCase();
    if (_currentPassword.length < 6) {
      return 'Informe sua senha atual.';
    }
    if (!isEmailValid(normalized)) {
      return 'Informe um e-mail válido.';
    }
    if (normalized != _confirmEmail.trim().toLowerCase()) {
      return 'A confirmação do novo e-mail não confere.';
    }
    if (normalized == _currentEmail.toLowerCase()) {
      return 'O novo e-mail deve ser diferente do atual.';
    }
    return null;
  }

  Future<void> handleSubmit() async {
    final validation = validateEmail();
    if (validation != null) {
      setState(() {
        _error = validation;
        _success = null;
      });
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
      _success = null;
    });
    try {
      await ProfileSecurityService.requestEmailChange(
        _currentPassword,
        _newEmail.trim().toLowerCase(),
      );
      setState(() {
        _currentPassword = '';
        _newEmail = '';
        _confirmEmail = '';
        _formNonce++;
        _success = 'Enviamos um link de confirmação para o novo e-mail.';
      });
    } catch (error) {
      setState(() => _error = error.toString());
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
              title: 'Trocar e-mail',
              onBack: () => context.pop(),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: ListView(
                  key: ValueKey(_formNonce),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  children: [
                    Text(
                      'Atualize o e-mail da sua conta',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Para trocar o e-mail, a conta exige dois fatores: sua '
                      'senha atual e um OTP enviado por SMS para o telefone '
                      'protegido.',
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.45,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 28),
                    AppTextField(
                      key: ValueKey('current-$_formNonce'),
                      label: 'Senha atual',
                      hint: 'Digite sua senha atual',
                      obscureText: true,
                      // Print CF-165: campo sem ícone de olho.
                      showObscureToggle: false,
                      onChanged: (value) =>
                          setState(() => _currentPassword = value),
                    ),
                    const SizedBox(height: 18),
                    AppTextField(
                      key: ValueKey('new-email-$_formNonce'),
                      label: 'Novo e-mail',
                      hint: 'novo@email.com',
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) => setState(() => _newEmail = value),
                    ),
                    const SizedBox(height: 18),
                    AppTextField(
                      key: ValueKey('confirm-email-$_formNonce'),
                      label: 'Confirmar novo e-mail',
                      hint: 'Repita o novo e-mail',
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) =>
                          setState(() => _confirmEmail = value),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      AccountFeedbackBanner(
                        message: _error!,
                        success: false,
                      ),
                    ],
                    if (_success != null) ...[
                      const SizedBox(height: 16),
                      AccountFeedbackBanner(
                        message: _success!,
                        success: true,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: AppButton(
                label: _submitting ? 'Atualizando...' : 'Enviar confirmação',
                disabled: _submitting || !_formReady,
                onPressed: handleSubmit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
