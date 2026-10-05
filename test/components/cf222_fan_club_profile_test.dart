import 'package:crowdfans/components/fan_club/fan_club_community_hero.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // GREEN — hero chrome do print (nome + Fã Clube mesma linha).
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

  // GREEN — helpers de print ainda montam Enzo/Aline (só para testes).
  test('CF-222 fixture feed: Enzo + Aline carousel + selo 3', () {
    expect(CfTempMocks.useFanClubFixtures, isFalse);
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

  // RED — demock: runtime flags off (service não short-circuita Enzo TEMP).
  test('CF-222 demock: FanClubService não usa fixtures em runtime', () {
    expect(CfTempMocks.useFanClubFixtures, isFalse);
    expect(kUseCf229ExpelledFixtures, isFalse);
    expect(kUseCf230WarningFixtures, isFalse);
    expect(kUseCf224RequestModerationMocks, isFalse);
    expect(kUseCf225ModeratorsMocks, isFalse);
    expect(kUseCf227FanClubPostMenuFixtures, isFalse);
    expect(kUseCf200DefendReturnFixtures, isFalse);
    expect(CfTempMocks.useModerationPanelFixtures, isFalse);
  });

  // EDGE — cover URL + hero com 0 membros / nome longo / favoritado.
  testWidgets('CF-222 edge: 0 membros e nome longo no hero', (tester) async {
    expect(cfTempMockFanClubCoverUrl, startsWith('http'));
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: FanClubCommunityHero(
            artistName: 'Artista Com Nome Bem Extenso Para Edge',
            memberCount: 0,
            isFavorite: true,
            onToggleFavorite: () {},
            onOpenArtist: () {},
            onAbout: () {},
            onRules: () {},
          ),
        ),
      ),
    );
    expect(find.textContaining('0'), findsWidgets);
    expect(find.textContaining('membros'), findsOneWidget);
    expect(
      find.text('Artista Com Nome Bem Extenso Para Edge'),
      findsOneWidget,
    );
    expect(find.byTooltip('Remover dos favoritos'), findsOneWidget);
    expect(
      FanClubCommunityHero.formatMemberCount(0),
      '0',
    );
    expect(
      FanClubCommunityHero.formatMemberCount(11841),
      '11.841',
    );
  });
}
