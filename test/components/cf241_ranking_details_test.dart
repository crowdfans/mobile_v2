import 'package:crowdfans/components/search/search_artist_rank_details_sheet.dart';
import 'package:crowdfans/components/search/search_artist_rank_metric_card.dart';
import 'package:crowdfans/components/search/search_rank_trend_dot.dart';
import 'package:crowdfans/services/search_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ArtistSearchItem.fromJson (CF-241)', () {
    test('lê trendDelta e previousRank da API', () {
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
      expect(item.rankDelta, 1);
      expect(item.trend, 'up');
      expect(item.previousRank, 2);
      expect(item.weeksInRanking, isNull);
      expect(item.peakRank, isNull);
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

  testWidgets('sheet agrupa métricas e separa Reportar; ausente vira —', (
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
}
