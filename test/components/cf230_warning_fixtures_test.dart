import 'package:crowdfans/components/fan_club/fan_club_moderation_warning_banner.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CF-230: flag TEMP + Laís Costa (aviso) sem tocar CF-229', () {
    expect(kUseCfTempMocks, isTrue);
    expect(kUseCf230WarningFixtures, isFalse);
    expect(cf230WarningFixturesEnabled(), isFalse);
    expect(cfTempMockLaisArtistUid, 'mock-fc-lais');
    expect(cfTempMockLaisCoverUrl, isNotEmpty);

    // CF-229 permanece ligado e isolado.
    expect(kUseCf229ExpelledFixtures, isFalse);
    expect(cfTempMockFelipeArtistUid, isNot(cfTempMockLaisArtistUid));
    expect(
      cfTempMockFanClubKind(cfTempMockLaisArtistUid),
      CfFanClubFixtureKind.warning,
    );
    expect(
      cfTempMockFanClubKind(cfTempMockFelipeArtistUid),
      CfFanClubFixtureKind.expelled,
    );
  });

  test('CF-230: fixture Laís — motivo, 2 chances, post Lari, nome limpo', () {
    final feed = cfTempMockArtistFanClubFeed(cfTempMockLaisArtistUid);
    final club = feed.fanClub;

    expect(club.artistName, 'Laís Costa');
    expect(club.name, 'Laís Costa');
    expect(club.name.toLowerCase().contains('fã clube'), isFalse);
    expect(club.memberCount, 8225);
    expect(club.viewerIsExpelled, isFalse);
    expect(club.viewerActiveStrikesCount, greaterThan(0));
    expect(club.viewerStrikeRemainingChances, 2);
    expect(club.viewerLatestStrikeReason, cfTempMockStrikeReason);
    expect(club.viewerLatestStrikeReason, contains('provocações repetidas'));

    expect(feed.posts, isNotEmpty);
    final post = feed.posts.first;
    expect(post.authorName, 'Lari Rocha');
    expect(post.authorHandle, 'fan/larirocha');
    expect(post.membershipMonthsLabel, '1');
    expect(post.content, contains('fã clube de BH'));
    expect((post.authorAvatarUri ?? '').trim(), isNotEmpty);
  });

  testWidgets('CF-230: banner usa motivo fixture e copy do print', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: FanClubModerationWarningBanner(
            reason: cfTempMockStrikeReason,
            remainingChances: 2,
          ),
        ),
      ),
    );

    expect(
      find.text('Você recebeu um aviso neste fã clube'),
      findsOneWidget,
    );
    expect(find.textContaining('provocações repetidas'), findsOneWidget);
    expect(
      find.text('Você ainda tem 2 chances para ajustar seu comportamento.'),
      findsOneWidget,
    );
    expect(find.text('Aviso de moderação'), findsNothing);
    expect(find.textContaining('chances restantes antes'), findsNothing);
  });
}
