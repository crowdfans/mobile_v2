import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

/// Documenta: mock só fica off quando a feature real existe.
void main() {
  test('TEMP mocks: só security/devices off (CF-266); resto até CF-267…270', () {
    expect(kUseCfTempMocks, isTrue);

    // Feature real: sessões /me/sessions
    expect(CfTempMocks.useSecuritySettingsFixtures, isFalse);

    // Ainda TEMP (backend gap)
    expect(kUseCf190NotificationMocks, isTrue); // CF-267
    expect(CfTempMocks.useArtistSobreFixtures, isTrue); // CF-269
    expect(kUseCf170WalletPackMocks, isTrue); // CF-270

    // Já wireados à API (batch1)
    expect(CfTempMocks.useRankingFixtures, isFalse);
    expect(CfTempMocks.useFanScoreFixtures, isFalse);
    expect(CfTempMocks.useMembershipFixtures, isFalse);
    expect(CfTempMocks.useNotificationPrefFixtures, isFalse);
    expect(CfTempMocks.useFanClubFixtures, isFalse);
    expect(CfTempMocks.useHomeFeedFixtures, isFalse);
    expect(CfTempMocks.useSearchArtistsFixtures, isFalse);
    expect(CfTempMocks.useFanClubSelectorFixtures, isFalse);
    expect(CfTempMocks.useArtistExclusiveFixtures, isFalse);
    expect(CfTempMocks.useModerationPanelFixtures, isFalse);
    expect(CfTempMocks.useNotificationCategoryPrintFixtures, isFalse);
    expect(CfTempMocks.useProfileAccountFixtures, isFalse);
    expect(CfTempMocks.useFavoriteArtistsFixtures, isFalse);
    expect(kUseCf194CommentMocks, isFalse);
    expect(kUseCf195CommentMocks, isFalse);
    expect(kUseCf178FanClubsFeedMocks, isFalse);
    expect(kUseCf181CartasMocks, isFalse);
  });
}
