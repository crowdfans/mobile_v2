final _emailRe = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

bool isEmailValid(String value) => _emailRe.hasMatch(value.trim());
