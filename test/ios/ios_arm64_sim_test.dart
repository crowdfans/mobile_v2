import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// CF-135 — CometChat não pode excluir arm64 no simulator (quebra Flutter no Apple Silicon).
void main() {
  final root = Directory.current.path.endsWith('mobile_v2')
      ? Directory.current
      : Directory('${Directory.current.path}/mobile_v2');

  test('Podfile remove EXCLUDED_ARCHS arm64 do simulator nos pods', () {
    final podfile = File('${root.path}/ios/Podfile').readAsStringSync();
    expect(
      podfile.contains("EXCLUDED_ARCHS[sdk=iphonesimulator*]"),
      isTrue,
      reason: 'post_install deve definir EXCLUDED_ARCHS do simulator',
    );
    expect(
      podfile.contains("'i386'"),
      isTrue,
      reason: 'só i386 deve ser excluído — WebRTC já tem slice arm64 sim',
    );
    expect(
      podfile.contains("= 'arm64 i386'") ||
          podfile.contains('= "arm64 i386"') ||
          podfile.contains("arm64 i386"),
      isFalse,
      reason: 'não reintroduzir exclusão de arm64 do simulator',
    );
  });
}
