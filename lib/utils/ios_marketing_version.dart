/// Mirrors Flutter's iOS `validatedBuildNameForPlatform` for CFBundleShortVersionString.
///
/// Apple requires at most three period-separated non-negative integers
/// (e.g. `0.1.1`). Flutter strips non `[0-9.]` chars from the pubspec build
/// name but does **not** truncate to three components — so `0.1.0-alpha.1`
/// becomes invalid `0.1.0.1`.
String iosMarketingVersionFromPubspec(String pubspecVersion) {
  final buildName = pubspecVersion.contains('+')
      ? pubspecVersion.split('+').first
      : pubspecVersion;
  final sanitized = buildName.replaceAll(RegExp(r'[^\d.]'), '');
  if (sanitized.isEmpty) {
    return '';
  }
  final segments = sanitized
      .split('.')
      .where((segment) => segment.isNotEmpty)
      .toList();
  while (segments.length < 3) {
    segments.add('0');
  }
  return segments.join('.');
}

/// Apple CFBundleShortVersionString: ≤3 period-separated non-negative integers.
bool isValidAppleShortVersion(String shortVersion) {
  return RegExp(r'^\d+(\.\d+){0,2}$').hasMatch(shortVersion);
}
