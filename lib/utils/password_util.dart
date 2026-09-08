final _strongPwRe = RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$');

bool isStrongPassword(String value) => _strongPwRe.hasMatch(value);

List<({String label, bool ok})> getPasswordChecks(String password) {
  return [
    (label: 'No minimo 8 caracteres', ok: password.length >= 8),
    (label: 'Uma letra maiuscula', ok: RegExp(r'[A-Z]').hasMatch(password)),
    (label: 'Um numero', ok: RegExp(r'\d').hasMatch(password)),
    (
      label: 'Um caractere especial',
      ok: RegExp(r'[^A-Za-z0-9]').hasMatch(password),
    ),
  ];
}
