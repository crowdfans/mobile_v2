import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/input/app_text_field.dart';
import 'package:crowdfans/components/profile/account_feedback_banner.dart';
import 'package:crowdfans/components/profile/password_requirements_card.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/profile_security_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Alterar senha — página dedicada (CF-164). Sem abas / sem Trocar e-mail.
class ProfileSecurityCredentialsScreen extends StatefulWidget {
  const ProfileSecurityCredentialsScreen({super.key, this.initialMode});

  /// Aceito por compatibilidade de rota; e-mail redireciona em [Pages].
  final String? initialMode;

  @override
  State<ProfileSecurityCredentialsScreen> createState() =>
      _ProfileSecurityCredentialsScreenState();
}

class _ProfileSecurityCredentialsScreenState
    extends State<ProfileSecurityCredentialsScreen> {
  var _currentPassword = '';
  var _newPassword = '';
  var _confirmPassword = '';
  var _submitting = false;
  var _formNonce = 0;
  String? _error;
  String? _success;

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

  Future<void> handleSubmit() async {
    final validation = validatePassword();
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
              title: 'Alterar senha',
              onBack: () => context.pop(),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
                  key: ValueKey(_formNonce),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 34),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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
                        'Use uma combinação forte para proteger sua conta e '
                        'evitar acessos indevidos.',
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
                        onChanged: (value) =>
                            setState(() => _currentPassword = value),
                      ),
                      const SizedBox(height: 18),
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
                            : 'Salvar nova senha',
                        disabled: _submitting || !_passwordFormReady,
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
}
