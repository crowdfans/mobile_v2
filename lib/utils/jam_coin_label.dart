/// Extrai base e bônus de labels de pacote (ex.: `200 JC + 40 bônus`).
///
/// Aceita milhar com ponto (`1.000 JC + 300 bônus`). Retorna null se o
/// rótulo não tiver breakdown de bônus (ex.: `120 JC`).
({int baseCoins, int bonusCoins})? parseJamCoinBonusLabel(String? label) {
  final raw = label?.trim() ?? '';
  if (raw.isEmpty) {
    return null;
  }
  final match = RegExp(
    r'^([\d.]+)\s*JC\s*\+\s*([\d.]+)\s*b[oô]nus',
    caseSensitive: false,
  ).firstMatch(raw);
  if (match == null) {
    return null;
  }
  final base = _parseGroupedInt(match.group(1));
  final bonus = _parseGroupedInt(match.group(2));
  if (base == null || bonus == null || bonus <= 0) {
    return null;
  }
  return (baseCoins: base, bonusCoins: bonus);
}

int? _parseGroupedInt(String? raw) {
  final digits = (raw ?? '').replaceAll('.', '').trim();
  if (digits.isEmpty) {
    return null;
  }
  return int.tryParse(digits);
}
