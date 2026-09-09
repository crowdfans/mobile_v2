import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/input/app_text_field.dart';
import 'package:crowdfans/components/profile/account_feedback_banner.dart';
import 'package:crowdfans/components/profile/password_requirements_card.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/components/profile/security_unavailable_card.dart';
import 'package:crowdfans/components/profile/settings_segmented_tabs.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/firebase_service.dart';
import 'package:crowdfans/services/profile_security_service.dart';
import 'package:crowdfans/utils/email_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum _SecurityMode { password, email }

/// Troca de senha e e-mail via Firebase Auth.
class ProfileSecurityScreen extends StatefulWidget {
  const ProfileSecurityScreen({super.key});

  @override
  State<ProfileSecurityScreen> createState() => _ProfileSecurityScreenState();
}

class _ProfileSecurityScreenState extends State<ProfileSecurityScreen> {
  var _mode = _SecurityMode.password;
  var _currentPassword = '';
  var _newPassword = '';
  var _confirmPassword = '';
  var _newEmail = '';
  var _confirmEmail = '';
  var _submitting = false;
  var _formNonce = 0;
  String? _error;
  String? _success;

  String get _currentEmail =>
      FirebaseService.auth.currentUser?.email ?? 'não informado';

  void handleSelectMode(int index) {
    setState(() {
      _mode = index == 0 ? _SecurityMode.password : _SecurityMode.email;
      _error = null;
      _success = null;
    });
  }

  String? validatePassword() {
    if (_currentPassword.length < 6) {
      return 'Informe sua senha atual.';
    }
    final hasUpper = RegExp(r'[A-Z]').hasMatch(_newPassword);
    final hasNumber = RegExp(r'\d').hasMatch(_newPassword);
    if (_newPassword.length < 8 || !hasUpper || !hasNumber) {
      return 'A nova senha deve ter 8 caracteres, uma maiúscula e um número.';
    }
    if (_newPassword != _confirmPassword) {
      return 'A confirmação da nova senha não confere.';
    }
    return null;
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
    final validation = _mode == _SecurityMode.password
        ? validatePassword()
        : validateEmail();
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
      if (_mode == _SecurityMode.password) {
        await ProfileSecurityService.changePassword(
          _currentPassword,
          _newPassword,
        );
        setState(() {
          _currentPassword = '';
          _newPassword = '';
          _confirmPassword = '';
          _formNonce++;
          _success = 'Senha alterada com sucesso.';
        });
      } else {
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
      }
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
    final isPassword = _mode == _SecurityMode.password;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            ProfileScreenHeader(
              title: 'Segurança e login',
              onBack: () => context.pop(),
            ),
            Expanded(
              child: ListView(
                key: ValueKey(_formNonce),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 34),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  SettingsSegmentedTabs(
                    labels: const ['Alterar senha', 'Trocar e-mail'],
                    selectedIndex: isPassword ? 0 : 1,
                    onChanged: handleSelectMode,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isPassword
                        ? 'Confirme sua senha atual antes de definir uma nova senha.'
                        : 'E-mail atual: $_currentEmail. O Firebase enviará a confirmação ao novo endereço.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    key: ValueKey('current-$_formNonce'),
                    label: 'Senha atual',
                    hint: 'Sua senha atual',
                    obscureText: true,
                    onChanged: (value) => _currentPassword = value,
                  ),
                  const SizedBox(height: 16),
                  if (isPassword) ...[
                    AppTextField(
                      key: ValueKey('new-pw-$_formNonce'),
                      label: 'Nova senha',
                      hint: 'Nova senha',
                      obscureText: true,
                      onChanged: (value) =>
                          setState(() => _newPassword = value),
                    ),
                    const SizedBox(height: 12),
                    PasswordRequirementsCard(
                      password: _newPassword,
                      confirmPassword: _confirmPassword,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      key: ValueKey('confirm-pw-$_formNonce'),
                      label: 'Confirmar nova senha',
                      hint: 'Repita a nova senha',
                      obscureText: true,
                      onChanged: (value) =>
                          setState(() => _confirmPassword = value),
                    ),
                  ] else ...[
                    AppTextField(
                      key: ValueKey('new-email-$_formNonce'),
                      label: 'Novo e-mail',
                      hint: 'novo@email.com',
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) => _newEmail = value,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      key: ValueKey('confirm-email-$_formNonce'),
                      label: 'Confirmar novo e-mail',
                      hint: 'Repita o novo e-mail',
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) => _confirmEmail = value,
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
                  const SizedBox(height: 16),
                  AppButton(
                    label: _submitting
                        ? 'Atualizando...'
                        : isPassword
                        ? 'Alterar senha'
                        : 'Enviar confirmação',
                    disabled: _submitting,
                    onPressed: handleSubmit,
                  ),
                  const SizedBox(height: 16),
                  const SecurityUnavailableCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
