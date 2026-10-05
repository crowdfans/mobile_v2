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
