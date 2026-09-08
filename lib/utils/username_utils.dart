final _usernameRe = RegExp(r'^[a-z0-9._]{3,20}$');

String normalizeUsername(String value) {
  return value
      .toLowerCase()
      .replaceAll(RegExp(r'\s+'), '')
      .replaceAll(RegExp(r'[^a-z0-9._]'), '');
}

bool isUsernameValid(String value) => _usernameRe.hasMatch(value.trim());
