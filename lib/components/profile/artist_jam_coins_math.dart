/// Conversão e retenção dos prints de Jam Coins Artista (CF-118).
abstract final class ArtistJamCoinsMath {
  static const jamCoinsReferenceAmount = 240;
  static const reaisReferenceAmount = 19.9;
  static const platformFeeRate = 0.3;

  static double convertJamCoinsToReais(num value) {
    return (value / jamCoinsReferenceAmount) * reaisReferenceAmount;
  }

  static String formatPtBr(num value, {int fractionDigits = 0}) {
    final fixed = value.toStringAsFixed(fractionDigits);
    final parts = fixed.split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
    if (fractionDigits == 0) {
      return intPart;
    }
    return '$intPart,${parts[1]}';
  }

  static String formatReais(num value) {
    return '≈ R\$ ${formatPtBr(value, fractionDigits: 2)}';
  }
}
