import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

/// Documenta: mock só fica off quando a feature real existe.
void main() {
  test('TEMP mocks: devices+inbox off; packs/Sobre até CF-270/269', () {
    expect(kUseCfTempMocks, isTrue);

    expect(CfTempMocks.useSecuritySettingsFixtures, isFalse); // CF-266 API
    expect(kUseCf216ConnectedDevicesMocks, isFalse); // CF-266 /me/sessions
    expect(kUseCf190NotificationMocks, isFalse); // CF-267

    expect(CfTempMocks.useArtistSobreFixtures, isFalse); // CF-269
    expect(kUseCf170WalletPackMocks, isFalse); // CF-270 democked
    expect(kUseCf171PixCheckoutMocks, isFalse); // CF-171 demock — PIX pending API

    expect(CfTempMocks.useRankingFixtures, isFalse); // CF-268 demock
    expect(CfTempMocks.useFanScoreFixtures, isFalse); // CF-201 demock Insights
    expect(CfTempMocks.useMembershipFixtures, isFalse); // CF-206 demock Assinar
    expect(CfTempMocks.useMembershipManageFixtures, isFalse); // CF-205 demock
    expect(
      CfTempMocks.useMembershipActivationConfirmedFixtures,
      isTrue,
    ); // CF-207 print
    expect(CfTempMocks.useNotificationPrefFixtures, isFalse);
    expect(CfTempMocks.useArtistsNotifPrintFixtures, isFalse); // CF-213 demock
    expect(CfTempMocks.useFanClubFixtures, isFalse); // demock CF-222…230
    expect(kUseCf200DefendReturnFixtures, isFalse); // CF-200 demock
    expect(kUseCf227FanClubPostMenuFixtures, isFalse); // CF-227 demock
    expect(kUseCf224RequestModerationMocks, isFalse); // CF-224 demock
    expect(kUseCf225ModeratorsMocks, isFalse); // CF-225 demock
    expect(kUseCf229ExpelledFixtures, isFalse); // CF-229 demock
    expect(kUseCf230WarningFixtures, isFalse); // CF-230 demock
    expect(CfTempMocks.useModerationPanelFixtures, isFalse); // CF-199 demock
    expect(CfTempMocks.useHomeFeedFixtures, isFalse); // demock GET /home
    expect(kUseCf176PostOptionsMocks, isFalse); // CF-176 demock menu ⋯
    expect(CfTempMocks.useSearchArtistsFixtures, isFalse); // CF-240 demock
    expect(CfTempMocks.useFanClubSelectorFixtures, isFalse); // CF-237 demock
    expect(CfTempMocks.useArtistExclusiveFixtures, isFalse); // CF-184/239 demock
    expect(CfTempMocks.useHelpFixtures, isFalse); // CF-198 HelpContent oficial
    expect(kUseCf198HelpMocks, isFalse); // CF-198 demock
    expect(kCf198MockEmpty, isFalse);
    expect(CfTempMocks.useNotificationCategoryPrintFixtures, isFalse);
    expect(CfTempMocks.useInteractionsNotifPrintFixtures, isFalse); // CF-208 API
    expect(CfTempMocks.useMeetGreetNotifPrintFixtures, isFalse); // CF-209 demock
    expect(CfTempMocks.useMembershipNotifPrintFixtures, isFalse); // CF-211 demock
    expect(CfTempMocks.useProfileAccountFixtures, isFalse);
    expect(CfTempMocks.useFavoriteArtistsFixtures, isFalse); // CF-191 demock
    expect(kUseCf185ArtistFeedMocks, isFalse); // CF-185 demock capa/CTA Feed
    expect(kUseCf194CommentMocks, isFalse); // CF-194 demock — comments API
    expect(kUseCf195CommentMocks, isFalse); // CF-195 demock — Home comments API
    expect(kUseCf196CommentMocks, isFalse); // CF-196 demock — reply+teclado real
    expect(kUseCf197GifMocks, isFalse); // CF-197 demock — Tenor / erro seguro
    expect(kUseCf178FanClubsFeedMocks, isFalse);
    expect(kUseCf181CartasMocks, isFalse); // CF-181 demock — fan-letters API
    expect(kUseCf187MeProfileMocks, isFalse); // CF-187 demock Meu Perfil API
    expect(kUseCf219EditBioMock, isFalse); // CF-219 demock — description API + seed
  });
}
