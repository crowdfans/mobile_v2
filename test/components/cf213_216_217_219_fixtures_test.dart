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

  test('CF-216 fixtures: três sessões do print (helpers; flag off)', () {
    expect(kUseCf216ConnectedDevicesMocks, isFalse);
    final sessions = Cf216ConnectedDevicesFixtures.sessions();
    expect(sessions.length, 3);
    expect(sessions.first.name, 'iPhone 15 Pro');
    expect(sessions.first.isCurrent, isTrue);
    expect(sessions.first.platformLine, 'iOS · Crowd Fans App');
    expect(sessions.first.location, 'São Paulo, Brasil');
    expect(sessions[1].name, 'MacBook Air');
    expect(sessions[1].isPhone, isFalse);
    expect(sessions[2].name, 'Galaxy S24');
    expect(sessions[2].location, 'Campinas, Brasil');
  });

  test('CF-219 fixtures: bio do print', () {
    // CF-217 demock: telefone vem de GET /profile + Firebase (sem Cf217ChangePhoneMock).
    expect(Cf219EditBioMock.bio.length, 56);
  });
}
