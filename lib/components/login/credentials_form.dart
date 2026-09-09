import 'package:crowdfans/components/login/password_field.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Form de e-mail, senha, entrar e esqueci senha.
class CredentialsForm extends StatelessWidget {
  const CredentialsForm({
    super.key,
    required this.email,
    required this.password,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onSubmit,
    required this.onForgotPassword,
    this.loading = false,
  });

  final String email;
  final String password;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPasswordChanged;
  final VoidCallback onSubmit;
  final VoidCallback onForgotPassword;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Column(
      children: [
        SizedBox(
          height: 45,
          child: TextField(
            key: const Key('login-username'),
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            textInputAction: TextInputAction.next,
            onChanged: onEmailChanged,
            decoration: InputDecoration(
              hintText: 'E-mail',
              hintStyle: TextStyle(color: colors.textTertiary),
              filled: true,
              fillColor: colors.inputBackground,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colors.inputBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colors.primary),
              ),
            ),
            style: TextStyle(color: colors.textPrimary, fontSize: 18),
          ),
        ),
        const SizedBox(height: 16),
        PasswordField(onChanged: onPasswordChanged),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton(
            key: const Key('login-submit'),
            onPressed: loading ? null : onSubmit,
            style: FilledButton.styleFrom(
              backgroundColor: colors.buttonPrimary,
              foregroundColor: colors.buttonPrimaryText,
              shape: const StadiumBorder(),
            ),
            child: Text(
              loading ? 'Carregando...' : 'Entrar',
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          key: const Key('login-forgot'),
          onPressed: onForgotPassword,
          child: Text(
            'Esqueceu seu login ou senha?',
            style: TextStyle(color: colors.textTertiary, fontSize: 16),
          ),
        ),
      ],
    );
  }
}
