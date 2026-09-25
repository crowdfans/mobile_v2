import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/input/app_text_field.dart';
import 'package:crowdfans/components/profile/account_feedback_banner.dart';
import 'package:crowdfans/components/profile/password_requirements_card.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/firebase_service.dart';
import 'package:crowdfans/services/profile_security_service.dart';
import 'package:crowdfans/utils/email_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum _SecurityMode { password, email }

/// Telas dedicadas Alterar senha (CF-164) e Trocar e-mail (CF-165) — sem abas.
class ProfileSecurityCredentialsScreen extends StatefulWidget {
  const ProfileSecurityCredentialsScreen({super.key, this.initialMode});

  /// `password` ou `email`.
  final String? initialMode;

  @override
  State<ProfileSecurityCredentialsScreen> createState() =>
      _ProfileSecurityCredentialsScreenState();
}

class _ProfileSecurityCredentialsScreenState
    extends State<ProfileSecurityCredentialsScreen> {
  late final _SecurityMode _mode;
  var _currentPassword = '';
  var _newPassword = '';
  var _confirmPassword = '';
  var _newEmail = '';
  var _confirmEmail = '';
  var _submitting = false;
  var _formNonce = 0;
  String? _error;
  String? _success;

  @override
  void initState() {
    super.initState();
    _mode = (widget.initialMode ?? '').toLowerCase() == 'email'
        ? _SecurityMode.email
        : _SecurityMode.password;
  }

  String get _currentEmail {
    try {
      return FirebaseService.auth.currentUser?.email ?? '';
    } catch (_) {
      // Testes / Firebase ainda não inicializado.
      return '';
    }
  }

  bool get _passwordFormReady {
    if (_currentPassword.length < 6) {
      return false;
    }
    final hasUpper = RegExp(r'[A-Z]').hasMatch(_newPassword);
    final hasNumber = RegExp(r'\d').hasMatch(_newPassword);
    if (_newPassword.length < 8 || !hasUpper || !hasNumber) {
      return false;
    }
    return _newPassword == _confirmPassword;
  }

  bool get _emailFormReady {
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
              title: isPassword ? 'Alterar senha' : 'Trocar e-mail',
              onBack: () => context.pop(),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
                  key: ValueKey('$_formNonce-$_mode'),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 34),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (isPassword)
                        ..._passwordIntro(colors)
                      else
                        ..._emailIntro(colors),
                      const SizedBox(height: 28),
                      AppTextField(
                        key: ValueKey('current-$_formNonce'),
                        label: 'Senha atual',
                        hint: 'Digite sua senha atual',
                        obscureText: true,
                        onChanged: (value) =>
                            setState(() => _currentPassword = value),
                      ),
                      const SizedBox(height: 18),
                      if (isPassword) ...[
                        AppTextField(
                          key: ValueKey('new-pw-$_formNonce'),
                          label: 'Nova senha',
                          hint: 'Digite sua nova senha',
                          obscureText: true,
                          onChanged: (value) =>
                              setState(() => _newPassword = value),
                        ),
                        const SizedBox(height: 18),
                        AppTextField(
                          key: ValueKey('confirm-pw-$_formNonce'),
                          label: 'Confirmar nova senha',
                          hint: 'Repita a nova senha',
                          obscureText: true,
                          onChanged: (value) =>
                              setState(() => _confirmPassword = value),
                        ),
                        const SizedBox(height: 28),
                        PasswordRequirementsCard(
                          password: _newPassword,
                          confirmPassword: _confirmPassword,
                        ),
                      ] else ...[
                        AppTextField(
                          key: ValueKey('new-email-$_formNonce'),
                          label: 'Novo e-mail',
                          hint: 'novo@email.com',
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (value) =>
                              setState(() => _newEmail = value),
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
                      ],
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
                      const SizedBox(height: 28),
                      AppButton(
                        label: _submitting
                            ? 'Atualizando...'
                            : isPassword
                            ? 'Salvar nova senha'
                            : 'Enviar confirmação',
                        disabled: _submitting ||
                            (isPassword
                                ? !_passwordFormReady
                                : !_emailFormReady),
                        onPressed: handleSubmit,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _passwordIntro(AppColors colors) {
    return [
      Text(
        'Atualize sua senha de acesso',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          height: 1.25,
          color: colors.textPrimary,
        ),
      ),
      const SizedBox(height: 10),
      Text(
        'Use uma combinação forte para proteger sua conta e evitar acessos indevidos.',
        style: TextStyle(
          fontSize: 15,
          height: 1.45,
          color: colors.textSecondary,
        ),
      ),
    ];
  }

  List<Widget> _emailIntro(AppColors colors) {
    return [
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
        'Para trocar o e-mail, a conta exige dois fatores: sua senha atual e um OTP enviado por SMS para o telefone protegido.',
        style: TextStyle(
          fontSize: 15,
          height: 1.45,
          color: colors.textSecondary,
        ),
      ),
    ];
  }
}
