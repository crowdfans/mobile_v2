import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/utils/phone_utils.dart';
import 'package:flutter/material.dart';

/// Campo de telefone do cadastro (altura 57, máscara BR).
class RegisterPhoneField extends StatelessWidget {
  const RegisterPhoneField({
    super.key,
    required this.controller,
    required this.onDigitsChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onDigitsChanged;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return SizedBox(
      height: 57,
      child: TextField(
        key: const Key('register-phone-input'),
        controller: controller,
        keyboardType: TextInputType.phone,
        onChanged: (value) {
          final digits = sanitizePhoneNumber(value);
          final formatted = formatPhoneNumber(digits);
          if (formatted != controller.text) {
            controller.value = TextEditingValue(
              text: formatted,
              selection: TextSelection.collapsed(offset: formatted.length),
            );
          }
          onDigitsChanged(digits);
        },
        decoration: InputDecoration(
          hintText: '(11) 91234-5678',
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
        style: TextStyle(color: colors.textPrimary, fontSize: 16),
      ),
    );
  }
}
