import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/services/notification_preferences_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CF-213 fixtures: tipos off + três artistas do print', () {
    final prefs = Cf213NotificationPrefFixtures.alertTypeDefaultsOff();
    expect(prefs[NotificationPreferenceKeys.clubPosts], isFalse);
    expect(prefs[NotificationPreferenceKeys.exclusiveContent], isFalse);
    expect(prefs[NotificationPreferenceKeys.fanLetterReceived], isFalse);
    expect(prefs[NotificationPreferenceKeys.artistHighlights], isFalse);

    final artists = Cf213NotificationPrefFixtures.followedArtists();
    expect(artists.map((a) => a.artistName), [
      'Mayra',
      'Laís Costa',
      'Marinhos',
    ]);
    expect(Cf213NotificationPrefFixtures.artistSubtitles.length, 3);
  });

  test('CF-216 fixtures: três sessões do print', () {
    final sessions = Cf216ConnectedDevicesFixtures.sessions();
    expect(sessions.length, 3);
    expect(sessions.first.name, 'iPhone 15 Pro');
    expect(sessions.first.isCurrent, isTrue);
    expect(sessions[1].name, 'MacBook Air');
    expect(sessions[2].name, 'Galaxy S24');
  });

  test('CF-217/219 fixtures: telefone e bio do print', () {
    expect(Cf217ChangePhoneMock.currentPhoneLabel, '(11) 98765-4321');
    expect(Cf219EditBioMock.bio.length, 56);
  });
}
