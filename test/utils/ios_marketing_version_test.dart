import 'dart:io';

import 'package:crowdfans/utils/ios_marketing_version.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('prerelease pubspec maps to invalid 4-part iOS short version', () {
    expect(iosMarketingVersionFromPubspec('0.1.0-alpha.1+1'), '0.1.0.1');
    expect(isValidAppleShortVersion('0.1.0.1'), isFalse);
  });

  test('pubspec version maps to Apple-valid CFBundleShortVersionString', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final versionLine = RegExp(r'^version:\s*(\S+)', multiLine: true)
        .firstMatch(pubspec)!
        .group(1)!;
    final short = iosMarketingVersionFromPubspec(versionLine);
    expect(
      isValidAppleShortVersion(short),
      isTrue,
      reason: 'got "$short" from pubspec "$versionLine" '
          '(Apple allows at most three period-separated integers)',
    );
    expect(short.split('.').length, lessThanOrEqualTo(3));
  });
}
