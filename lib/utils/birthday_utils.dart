/// Data máxima de nascimento para ter pelo menos 13 anos.
DateTime maxAllowedBirthDate() {
  final today = DateTime.now();
  return DateTime(today.year - 13, today.month, today.day);
}
