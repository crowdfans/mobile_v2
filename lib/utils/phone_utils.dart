bool isPhonePartsValid(String countryCode, String phoneNumber) {
  final countryDigits = countryCode.replaceAll(RegExp(r'\D'), '');
  final phoneDigits = phoneNumber.replaceAll(RegExp(r'\D'), '');
  return countryDigits.isNotEmpty && phoneDigits.length >= 10;
}

String formatPhoneNumber(String value) {
  final digits = value.replaceAll(RegExp(r'\D'), '');
  final clipped = digits.length > 11 ? digits.substring(0, 11) : digits;
  if (clipped.length <= 2) {
    return clipped.isEmpty ? '' : '($clipped';
  }
  final area = clipped.substring(0, 2);
  final local = clipped.substring(2);
  if (local.length <= 5) {
    return '($area) $local';
  }
  return '($area) ${local.substring(0, 5)}-${local.substring(5)}';
}

String formatPhoneDisplay(String countryCode, String phoneNumber) {
  final formatted = formatPhoneNumber(phoneNumber);
  if (formatted.isEmpty) {
    return countryCode;
  }
  return '$countryCode $formatted';
}

String sanitizePhoneNumber(String value) {
  final digits = value.replaceAll(RegExp(r'\D'), '');
  return digits.length > 11 ? digits.substring(0, 11) : digits;
}
