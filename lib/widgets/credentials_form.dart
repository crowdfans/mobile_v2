import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

class CredentialsForm extends StatelessWidget {
  const CredentialsForm({
    super.key,
    required this.email,
    required this.password,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onSubmit,
    required this.onForgotPassword,
  });

  final String email;
  final String password;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPasswordChanged;
  final VoidCallback onSubmit;
  final VoidCallback onForgotPassword;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Column(
      children: [
        TextField(
          key: const Key('login-username'),
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          onChanged: onEmailChanged,
          decoration: InputDecoration(
            hintText: 'E-mail',
            hintStyle: TextStyle(color: colors.textTertiary),
            filled: true,
            fillColor: colors.inputBackground,
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
        const SizedBox(height: 16),
        _PasswordField(onChanged: onPasswordChanged),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton(
            key: const Key('login-submit'),
            onPressed: onSubmit,
            style: FilledButton.styleFrom(
              backgroundColor: colors.buttonPrimary,
              foregroundColor: colors.buttonPrimaryText,
              shape: const StadiumBorder(),
            ),
            child: const Text('Entrar', style: TextStyle(fontSize: 18)),
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

class _PasswordField extends StatefulWidget {
  const _PasswordField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return TextField(
      key: const Key('login-password'),
      obscureText: !_visible,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        hintText: 'Senha',
        hintStyle: TextStyle(color: colors.textTertiary),
        filled: true,
        fillColor: colors.inputBackground,
        suffixIcon: IconButton(
          onPressed: () => setState(() => _visible = !_visible),
          icon: Icon(
            _visible ? Icons.visibility_off : Icons.visibility,
            color: colors.textSecondary,
          ),
        ),
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
    );
  }
}
