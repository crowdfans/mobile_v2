import 'package:crowdfans/components/search/search_artist_rank_details_sheet.dart';
import 'package:crowdfans/components/search/search_artist_rank_metric_card.dart';
import 'package:crowdfans/components/search/search_rank_trend_dot.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/services/search_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ArtistSearchItem.fromJson (CF-241 / CF-268)', () {
    test('green: lê weeksInRanking + peakRank da API', () {
      final item = ArtistSearchItem.fromJson({
        'id': 'a1',
        'name': 'Ludmilla',
        'handle': 'ludmilla',
        'avatarUri': '',
        'memberCount': 512000,
        'membersLabel': '512 mil membros',
        'rank': 1,
        'trend': 'up',
        'trendDelta': 1,
        'previousRank': 2,
        'weeksInRanking': 11,
        'peakRank': 1,
      });
      expect(item.rankDelta, 1);
      expect(item.trend, 'up');
      expect(item.previousRank, 2);
      expect(item.weeksInRanking, 11);
      expect(item.peakRank, 1);
    });

    test('red: campos ausentes → null (sheet mostra —)', () {
      final item = ArtistSearchItem.fromJson({
        'id': 'a1',
        'name': 'Ludmilla',
        'handle': 'ludmilla',
        'avatarUri': '',
        'memberCount': 512000,
        'membersLabel': '512 mil membros',
        'rank': 1,
        'trend': 'up',
        'trendDelta': 1,
        'previousRank': 2,
      });
      expect(item.weeksInRanking, isNull);
      expect(item.peakRank, isNull);
    });

    test('edge: peakRank via alias maxRank; zero inválido no sheet', () {
      final item = ArtistSearchItem.fromJson({
        'id': 'a1',
        'name': 'X',
        'handle': 'x',
        'avatarUri': '',
        'memberCount': 0,
        'membersLabel': '',
        'rank': 3,
        'maxRank': 2,
        'weeksInRanking': 0,
      });
      expect(item.peakRank, 2);
      expect(item.weeksInRanking, 0);
    });
  });

  group('searchRankTrendFromArtist', () {
    test('usa trend=down mesmo com trendDelta positivo', () {
      const item = ArtistSearchItem(
        id: 'a1',
        name: 'Anitta',
        handle: 'anitta',
        avatarUri: '',
        memberCount: 1,
        membersLabel: '1',
        rank: 2,
        trend: 'down',
        rankDelta: 3,
      );
      expect(searchRankTrendFromArtist(item), SearchRankTrend.down);
    });
  });

  test('CF-268 demock: ranking fixtures off; amostra print ainda disponível', () {
    expect(CfTempMocks.useRankingFixtures, isFalse);
    final ludmilla = cfTempMockRankingArtists(kind: 'fan-clubs').first;
    expect(ludmilla.name, 'Ludmilla');
    expect(ludmilla.rank, 1);
    expect(ludmilla.weeksInRanking, 11);
    expect(ludmilla.peakRank, 1);
    expect(ludmilla.previousRank, 2);
  });

  testWidgets('red/edge: sheet — quando weeks/peak ausentes; previousRank ok', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SearchArtistRankDetailsSheet(
            visible: true,
            artist: const ArtistSearchItem(
              id: 'a1',
              name: 'Ludmilla',
              handle: 'ludmilla',
              avatarUri: '',
              memberCount: 512000,
              membersLabel: '512 mil membros',
              rank: 1,
              trend: 'up',
              rankDelta: 1,
              previousRank: 2,
            ),
            onClose: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ludmilla'), findsOneWidget);
    expect(find.text('#1'), findsOneWidget);
    expect(find.text('Semanas no ranking'), findsOneWidget);
    expect(find.text('Posição máxima'), findsOneWidget);
    expect(find.text('Semana passada'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    // Indisponível ≠ zero.
    expect(find.text('—'), findsNWidgets(2));
    expect(find.text('0'), findsNothing);
    expect(find.text('Reportar'), findsOneWidget);
    expect(find.byType(SearchArtistRankMetricCard), findsNWidgets(3));
  });

  testWidgets('green: sheet Ludmilla com 11 / 1 / 2 + Reportar (DTO API)', (
    tester,
  ) async {
    const ludmilla = ArtistSearchItem(
      id: 'a1',
      name: 'Ludmilla',
      handle: 'ludmilla',
      avatarUri: '',
      memberCount: 512000,
      membersLabel: '512 mil membros',
      rank: 1,
      trend: 'up',
      rankDelta: 1,
      previousRank: 2,
      weeksInRanking: 11,
      peakRank: 1,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SearchArtistRankDetailsSheet(
            visible: true,
            artist: ludmilla,
            onClose: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ludmilla'), findsOneWidget);
    expect(find.text('#1'), findsOneWidget);
    expect(find.text('512 mil membros'), findsOneWidget);
    expect(find.text('Semanas no ranking'), findsOneWidget);
    expect(find.text('11'), findsOneWidget);
    expect(find.text('Posição máxima'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('Semana passada'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('—'), findsNothing);
    expect(find.text('0'), findsNothing);
    expect(find.text('Reportar'), findsOneWidget);
    expect(find.byType(SearchArtistRankMetricCard), findsNWidgets(3));
    expect(find.byType(SearchRankTrendDot), findsWidgets);
  });
}
