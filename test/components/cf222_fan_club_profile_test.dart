import 'package:crowdfans/components/fan_club/fan_club_community_hero.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/services/fan_club_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CF-222 hero: nome + Fã Clube na mesma linha e favorito', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: FanClubCommunityHero(
            artistName: 'Enzo Lima',
            memberCount: 11841,
            isFavorite: false,
            onToggleFavorite: () {},
            onOpenArtist: () {},
            onAbout: () {},
            onRules: () {},
          ),
        ),
      ),
    );

    expect(find.text('Enzo Lima'), findsOneWidget);
    expect(find.text('Fã Clube'), findsOneWidget);
    expect(find.textContaining('11.841'), findsOneWidget);
    expect(find.textContaining('membros'), findsOneWidget);
    expect(find.text('Ver mais'), findsOneWidget);
    expect(find.text('Regras'), findsOneWidget);
    expect(find.byTooltip('Favoritar'), findsOneWidget);

    // Print: nome e "Fã Clube" compartilham a mesma Row (não empilhados).
    final name = tester.getTopLeft(find.text('Enzo Lima'));
    final label = tester.getTopLeft(find.text('Fã Clube'));
    expect((name.dy - label.dy).abs(), lessThan(8));
    expect(label.dx, greaterThan(name.dx));
  });

  test('CF-222 fixture feed: Enzo + Aline carousel + selo 3', () {
    expect(CfTempMocks.useFanClubFixtures, isTrue);
    final feed = cfTempMockArtistFanClubFeed('mock-fc-enzo');
    expect(feed.fanClub.artistName, 'Enzo Lima');
    expect(feed.fanClub.memberCount, 11841);
    final post = feed.posts.first;
    expect(post.authorName, 'Aline Duarte');
    expect(post.authorHandle, 'fan/alineduarte');
    expect(post.membershipMonthsLabel, '3');
    expect(post.carouselUris.length, greaterThanOrEqualTo(2));
    expect(cfTempMockFanClubCoverUrl, isNotEmpty);
  });

  test('CF-222 FanClubService honra fixtures', () async {
    final feed = await FanClubService.getArtistFanClubFeed('any-enzo-artist');
    expect(feed, isNotNull);
    expect(feed!.fanClub.artistName, 'Enzo Lima');
    expect(feed.posts.first.authorHandle, 'fan/alineduarte');
  });
}
