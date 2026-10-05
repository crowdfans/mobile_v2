import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

/// Documenta: mock só fica off quando a feature real existe.
void main() {
  test('TEMP mocks: devices+inbox off; packs/Sobre até CF-270/269', () {
    expect(kUseCfTempMocks, isTrue);

    expect(CfTempMocks.useSecuritySettingsFixtures, isFalse); // CF-266 API
    expect(kUseCf216ConnectedDevicesMocks, isTrue); // print CF-216
    expect(kUseCf190NotificationMocks, isFalse); // CF-267

    expect(CfTempMocks.useArtistSobreFixtures, isTrue); // CF-269
    expect(kUseCf170WalletPackMocks, isTrue); // CF-270

    expect(CfTempMocks.useRankingFixtures, isTrue); // CF-189 até tendência real
    expect(CfTempMocks.useFanScoreFixtures, isTrue); // CF-201 print Insights
    expect(CfTempMocks.useMembershipFixtures, isFalse);
    expect(CfTempMocks.useNotificationPrefFixtures, isFalse);
    expect(CfTempMocks.useFanClubFixtures, isFalse);
    expect(CfTempMocks.useHomeFeedFixtures, isFalse);
    expect(CfTempMocks.useSearchArtistsFixtures, isFalse);
    expect(CfTempMocks.useFanClubSelectorFixtures, isFalse);
    expect(CfTempMocks.useArtistExclusiveFixtures, isFalse);
    expect(CfTempMocks.useModerationPanelFixtures, isTrue); // CF-199 print
    expect(CfTempMocks.useNotificationCategoryPrintFixtures, isFalse);
    expect(CfTempMocks.useMembershipNotifPrintFixtures, isTrue); // CF-211
    expect(CfTempMocks.useProfileAccountFixtures, isFalse);
    expect(CfTempMocks.useFavoriteArtistsFixtures, isFalse);
    expect(kUseCf194CommentMocks, isFalse);
    expect(kUseCf195CommentMocks, isFalse);
    expect(kUseCf178FanClubsFeedMocks, isFalse);
    expect(kUseCf181CartasMocks, isFalse);
  });
}
