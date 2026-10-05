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
    expect(
      CfTempMocks.useMembershipActivationConfirmedFixtures,
      isTrue,
    ); // CF-207 print
    expect(CfTempMocks.useNotificationPrefFixtures, isFalse);
    expect(CfTempMocks.useArtistsNotifPrintFixtures, isTrue); // CF-213
    expect(CfTempMocks.useFanClubFixtures, isTrue); // CF-186/222/223/227
    expect(kUseCf227FanClubPostMenuFixtures, isTrue); // CF-227 post menu
    expect(kUseCf224RequestModerationMocks, isTrue); // CF-224 Solicitar moderação
    expect(kUseCf225ModeratorsMocks, isTrue); // CF-225 Moderadores
    expect(kUseCf229ExpelledFixtures, isTrue); // CF-229 expelled banner
    expect(kUseCf230WarningFixtures, isTrue); // CF-230 warning banner
    expect(CfTempMocks.useHomeFeedFixtures, isTrue); // CF-232/233/234/235/236 feed print
    expect(CfTempMocks.useSearchArtistsFixtures, isTrue); // CF-240 TEMP
    expect(CfTempMocks.useFanClubSelectorFixtures, isTrue); // CF-237 TEMP
    expect(CfTempMocks.useArtistExclusiveFixtures, isTrue); // CF-184/239
    expect(CfTempMocks.useModerationPanelFixtures, isTrue); // CF-199 print
    expect(CfTempMocks.useNotificationCategoryPrintFixtures, isFalse);
    expect(CfTempMocks.useMeetGreetNotifPrintFixtures, isTrue); // CF-209
    expect(CfTempMocks.useMembershipNotifPrintFixtures, isTrue); // CF-211
    expect(CfTempMocks.useProfileAccountFixtures, isFalse);
    expect(CfTempMocks.useFavoriteArtistsFixtures, isFalse);
    expect(kUseCf185ArtistFeedMocks, isTrue); // CF-185 capa/CTA Feed
    expect(kUseCf194CommentMocks, isTrue); // CF-194 print até comments API
    expect(kUseCf195CommentMocks, isTrue); // CF-195 print Home
    expect(kUseCf178FanClubsFeedMocks, isFalse);
    expect(kUseCf181CartasMocks, isTrue); // CF-181 print Cartas até API povoada
  });
}
