import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Campo de senha com mostrar/ocultar.
class PasswordField extends StatefulWidget {
  const PasswordField({super.key, required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return SizedBox(
      height: 45,
      child: TextField(
        key: const Key('login-password'),
        obscureText: !_visible,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: 'Senha',
          hintStyle: TextStyle(color: colors.textTertiary),
          filled: true,
          fillColor: colors.inputBackground,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          suffixIcon: IconButton(
            onPressed: () => setState(() => _visible = !_visible),
            icon: Icon(
              _visible ? Icons.visibility_off : Icons.visibility,
              color: colors.textSecondary,
              size: 18,
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
      ),
    );
  }
}
