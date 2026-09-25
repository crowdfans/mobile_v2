import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CF-199 fixtures: Contestações 2 / Avisos 2 / Expulsos 1', () {
    final appeals = Cf199ModerationPanelFixtures.appeals();
    final strikes = Cf199ModerationPanelFixtures.strikes();
    final expulsions = Cf199ModerationPanelFixtures.expulsions();
    expect(appeals.length, 2);
    expect(strikes.length, 2);
    expect(expulsions.length, 1);
    expect(appeals[0].displayName, 'Anna Lu');
    expect(appeals[0].defense, contains('apaguei as publicações'));
    expect(appeals[1].displayName, 'Vic Melo');
    expect(appeals[1].handle, 'vicmelo');
  });
}
