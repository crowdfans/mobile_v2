import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guardarails de build iOS (CF-134): plist válido + min iOS para CometChat.
void main() {
  final root = Directory.current.path.endsWith('mobile_v2')
      ? Directory.current
      : Directory('${Directory.current.path}/mobile_v2');

  String path(String relative) => '${root.path}/$relative';

  test('Info.plist passa no plutil -lint (sem & sem escape)', () {
    final plist = File(path('ios/Runner/Info.plist'));
    expect(plist.existsSync(), isTrue);

    final result = Process.runSync('plutil', ['-lint', plist.path]);
    expect(
      result.exitCode,
      0,
      reason: 'stdout=${result.stdout}\nstderr=${result.stderr}',
    );
  });

  test('deployment target iOS >= 15.1 (cometchat_calls_sdk)', () {
    final podfile = File(path('ios/Podfile')).readAsStringSync();
    expect(
      podfile.contains("platform :ios, '15.1'"),
      isTrue,
      reason: 'Podfile deve declarar platform :ios, 15.1',
    );

    final pbx = File(path('ios/Runner.xcodeproj/project.pbxproj')).readAsStringSync();
    expect(
      pbx.contains('IPHONEOS_DEPLOYMENT_TARGET = 15.0'),
      isFalse,
      reason: 'project.pbxproj não pode ficar em 15.0',
    );
    expect(pbx.contains('IPHONEOS_DEPLOYMENT_TARGET = 15.1'), isTrue);
  });
}
