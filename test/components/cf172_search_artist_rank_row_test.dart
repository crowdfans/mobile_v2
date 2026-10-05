import 'package:crowdfans/components/search/search_artist_rank_row.dart';
import 'package:crowdfans/components/search/search_discovery_tile.dart';
import 'package:crowdfans/components/search/search_query_field.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/screens/search/search_screen.dart';
import 'package:crowdfans/services/search_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const artist = ArtistSearchItem(
    id: 'a1',
    name: 'Mayra',
    handle: '@mayra',
    avatarUri: '',
    memberCount: 12000,
    membersLabel: '12k membros',
    rank: 3,
    rankDelta: 1,
    trend: 'up',
  );

  test('CF-172 amostra: preview home = 3 linhas do print', () {
    expect(CfTempMocks.useRankingFixtures, isFalse); // CF-268
    final rows = cfTempMockRankingArtists(kind: 'fan-clubs', limit: 3);
    expect(rows.map((r) => r.name).toList(), ['Ludmilla', 'Anitta', 'Mayra']);
    expect(rows.map((r) => r.trend).toList(), ['up', 'down', 'neutral']);
    expect(rows[0].membersLabel, '512 mil membros');
  });

  testWidgets('CF-172: foto à esquerda e rank acima do nome', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: SearchArtistRankRow(
            artist: artist,
            position: 3,
            layout: SearchArtistRankRowLayout.avatarLeading,
            onPressed: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('#3'), findsOneWidget);
    expect(find.text('Mayra'), findsOneWidget);
    // Avatar (ClipRRect) precede o texto do badge na ordem visual avatarLeading.
    final clip = tester.getTopLeft(find.byType(ClipRRect).first);
    final badge = tester.getTopLeft(find.text('#3'));
    expect(clip.dx, lessThan(badge.dx));
  });

  testWidgets('CF-172 home: atalhos fotográficos + lupa (lista via API)', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: const SearchScreen(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Buscar artista'), findsOneWidget);
    expect(find.byType(SearchQueryField), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(SearchQueryField),
        matching: find.byType(SvgPicture),
      ),
      findsWidgets,
    );

    expect(find.byType(SearchDiscoveryTile), findsNWidgets(2));
    expect(find.text('Top 100\nEngajados'), findsOneWidget);
    expect(find.text('Top 500\nAtivos'), findsOneWidget);
    // Fixtures off (CF-268): preview de ranking vem da API — sem Ludmilla TEMP.
  });

  testWidgets('CF-193: # e tendência à esquerda do avatar (print Top 100)', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: SearchArtistRankRow(
            artist: artist,
            position: 3,
            layout: SearchArtistRankRowLayout.rankLeading,
            onPressed: () {},
            onPressMore: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('#3'), findsOneWidget);
    expect(find.text('Mayra'), findsOneWidget);
    final badge = tester.getTopLeft(find.text('#3'));
    final clip = tester.getTopLeft(find.byType(ClipRRect).first);
    expect(badge.dx, lessThan(clip.dx));
    expect(find.text('subiu'), findsNothing);
    expect(find.text('estável'), findsNothing);
  });
}
