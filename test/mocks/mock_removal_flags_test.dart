import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

/// Garante que nenhum TEMP mock de print fica ligado no app.
void main() {
  test('todos os TEMP mocks estão desligados (API / empty state)', () {
    expect(kUseCfTempMocks, isFalse);
    expect(kUseCf190NotificationMocks, isFalse);
    expect(kUseCf170WalletPackMocks, isFalse);
    expect(kUseCf194CommentMocks, isFalse);
    expect(kUseCf195CommentMocks, isFalse);
    expect(kUseCf178FanClubsFeedMocks, isFalse);
    expect(kUseCf181CartasMocks, isFalse);

    expect(CfTempMocks.useRankingFixtures, isFalse);
    expect(CfTempMocks.useFanScoreFixtures, isFalse);
    expect(CfTempMocks.useMembershipFixtures, isFalse);
    expect(CfTempMocks.useNotificationPrefFixtures, isFalse);
    expect(CfTempMocks.useSecuritySettingsFixtures, isFalse);
    expect(CfTempMocks.useFanClubFixtures, isFalse);
    expect(CfTempMocks.useHomeFeedFixtures, isFalse);
    expect(CfTempMocks.useSearchArtistsFixtures, isFalse);
    expect(CfTempMocks.useFanClubSelectorFixtures, isFalse);
    expect(CfTempMocks.useArtistExclusiveFixtures, isFalse);
    expect(CfTempMocks.useModerationPanelFixtures, isFalse);
    expect(CfTempMocks.useNotificationCategoryPrintFixtures, isFalse);
    expect(CfTempMocks.useProfileAccountFixtures, isFalse);
    expect(CfTempMocks.useArtistSobreFixtures, isFalse);
    expect(CfTempMocks.useFavoriteArtistsFixtures, isFalse);
  });
}
