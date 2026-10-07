import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final root = Directory.current.path.endsWith('mobile_v2')
      ? Directory.current
      : Directory('${Directory.current.path}/mobile_v2');

  test('AndroidManifest declara App Links HTTPS prod + staging placeholder', () {
    final manifest = File(
      '${root.path}/android/app/src/main/AndroidManifest.xml',
    );
    final text = manifest.readAsStringSync();
    expect(text, contains('android:autoVerify="true"'));
    expect(text, contains('android:host="crowdfans.app"'));
    expect(text, contains('android:host="www.crowdfans.app"'));
    expect(text, contains('android:host="staging.crowdfans.app"'));
    expect(text, contains('android:scheme="mobile"'));
  });

  test('iOS entitlements incluem associated domains staging placeholder', () {
    for (final name in ['RunnerRelease.entitlements', 'RunnerDebug.entitlements']) {
      final text =
          File('${root.path}/ios/Runner/$name').readAsStringSync();
      expect(text, contains('applinks:crowdfans.app'));
      expect(text, contains('applinks:www.crowdfans.app'));
      expect(text, contains('applinks:staging.crowdfans.app'));
    }
  });
}
