/// Omite mensagens internas (sandbox / RevenueCat / CF-*) em textos visíveis.
String? walletUserFacingMessage(String? raw) {
  final trimmed = raw?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  final lower = trimmed.toLowerCase();
  if (lower.contains('sandbox') ||
      lower.contains('revenuecat') ||
      RegExp(r'\bcf-\d+', caseSensitive: false).hasMatch(trimmed)) {
    return null;
  }
  return trimmed;
}

/// Validade do código PIX (print CF-171). [nowUtc] deve ser UTC.
String walletPixValidityLabel([DateTime? nowUtc]) {
  final utc = nowUtc ?? DateTime.now().toUtc();
  final brasilia = utc.subtract(const Duration(hours: 3));
  final until = brasilia.add(const Duration(minutes: 30));
  final hour = until.hour.toString().padLeft(2, '0');
  final minute = until.minute.toString().padLeft(2, '0');
  return 'Este código é válido até hoje, $hour:$minute - Horário de Brasília.';
}
