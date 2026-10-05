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
    expect(kUseCf171PixCheckoutMocks, isTrue); // CF-171 até PIX pending real

    expect(CfTempMocks.useRankingFixtures, isFalse); // CF-268 demock
    expect(CfTempMocks.useFanScoreFixtures, isTrue); // CF-201 print Insights
    expect(CfTempMocks.useMembershipFixtures, isFalse);
    expect(CfTempMocks.useMembershipManageFixtures, isTrue); // CF-205 print
    expect(
      CfTempMocks.useMembershipActivationConfirmedFixtures,
      isTrue,
    ); // CF-207 print
    expect(CfTempMocks.useNotificationPrefFixtures, isFalse);
    expect(CfTempMocks.useArtistsNotifPrintFixtures, isTrue); // CF-213
    expect(CfTempMocks.useFanClubFixtures, isTrue); // CF-186/222/223/227
    expect(kUseCf200DefendReturnFixtures, isTrue); // CF-200 Defender retorno
    expect(kUseCf227FanClubPostMenuFixtures, isTrue); // CF-227 post menu
    expect(kUseCf224RequestModerationMocks, isTrue); // CF-224 Solicitar moderação
    expect(kUseCf225ModeratorsMocks, isTrue); // CF-225 Moderadores
    expect(kUseCf229ExpelledFixtures, isTrue); // CF-229 expelled banner
    expect(kUseCf230WarningFixtures, isTrue); // CF-230 warning banner
    expect(CfTempMocks.useHomeFeedFixtures, isTrue); // CF-175/176/232/233/234/235/236
    expect(kUseCf176PostOptionsMocks, isTrue); // CF-176 menu ⋯ print
    expect(CfTempMocks.useSearchArtistsFixtures, isFalse); // CF-240 demock
    expect(CfTempMocks.useFanClubSelectorFixtures, isTrue); // CF-237 TEMP
    expect(CfTempMocks.useArtistExclusiveFixtures, isTrue); // CF-184/239
    expect(CfTempMocks.useModerationPanelFixtures, isTrue); // CF-199 print
    expect(CfTempMocks.useHelpFixtures, isFalse); // CF-198 HelpContent oficial
    expect(kUseCf198HelpMocks, isFalse); // CF-198 demock
    expect(kCf198MockEmpty, isFalse);
    expect(CfTempMocks.useNotificationCategoryPrintFixtures, isFalse);
    expect(CfTempMocks.useInteractionsNotifPrintFixtures, isFalse); // CF-208 API
    expect(CfTempMocks.useMeetGreetNotifPrintFixtures, isTrue); // CF-209
    expect(CfTempMocks.useMembershipNotifPrintFixtures, isTrue); // CF-211
    expect(CfTempMocks.useProfileAccountFixtures, isFalse);
    expect(CfTempMocks.useFavoriteArtistsFixtures, isFalse); // CF-191 demock
    expect(kUseCf185ArtistFeedMocks, isTrue); // CF-185 capa/CTA Feed
    expect(kUseCf194CommentMocks, isFalse); // CF-194 demock — comments API
    expect(kUseCf195CommentMocks, isFalse); // CF-195 demock — Home comments API
    expect(kUseCf196CommentMocks, isFalse); // CF-196 demock — reply+teclado real
    expect(kUseCf197GifMocks, isTrue); // CF-197 seletor GIF TEMP
    expect(kUseCf178FanClubsFeedMocks, isFalse);
    expect(kUseCf181CartasMocks, isFalse); // CF-181 demock — fan-letters API
    expect(kUseCf187MeProfileMocks, isFalse); // CF-187 demock Meu Perfil API
  });
}
