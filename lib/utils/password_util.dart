import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

final _strongPwRe = RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$');

bool isStrongPassword(String value) => _strongPwRe.hasMatch(value);

List<({String label, bool ok})> getPasswordChecks(String password) {
  return [
    (label: 'No mínimo 8 caracteres', ok: password.length >= 8),
    (label: 'Uma letra maiúscula', ok: RegExp(r'[A-Z]').hasMatch(password)),
    (label: 'Um número', ok: RegExp(r'\d').hasMatch(password)),
    (
      label: 'Um caractere especial',
      ok: RegExp(r'[^A-Za-z0-9]').hasMatch(password),
    ),
  ];
}

String passwordStrengthLabel(int score) {
  if (score <= 1) {
    return 'Muito fraca';
  }
  if (score == 2) {
    return 'Fraca';
  }
  if (score == 3) {
    return 'Média';
  }
  return 'Forte';
}

Color passwordStrengthColor(int score) {
  if (score <= 2) {
    return AppPalette.red500;
  }
  if (score == 3) {
    return AppPalette.orange600;
  }
  if (score == 4) {
    return AppPalette.blue700;
  }
  return AppPalette.green700;
}
