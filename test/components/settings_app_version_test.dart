import 'package:crowdfans/components/profile/settings_app_version.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formatAppVersionLabel: marketing + build para QA', () {
    expect(formatAppVersionLabel('0.1.1', '2'), '0.1.1 (2)');
    expect(formatAppVersionLabel('0.1.1', '1'), '0.1.1 (1)');
  });

  test('formatAppVersionLabel: trim e vazios', () {
    expect(formatAppVersionLabel(' 0.1.1 ', ' 2 '), '0.1.1 (2)');
    expect(formatAppVersionLabel('', '2'), '(2)');
    expect(formatAppVersionLabel('0.1.1', ''), '0.1.1');
    expect(formatAppVersionLabel('', ''), '');
  });
}
