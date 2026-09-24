import 'package:crowdfans/components/profile/fan_score_artist_card.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/fan_score.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const entry = FanScoreEntry(
    artistId: 'a1',
    artistName: 'Kheper',
    artistAvatarUri: '',
    memberCount: '141k',
    currentScore: 1000,
    deltaPercentage: 4,
    fanRank: 7,
    breakdown: FanScoreBreakdown(
      hasMembership: true,
      commentsMade: 100,
      upvotesMade: 60,
      fanLettersPosted: 20,
      liveDonations: 5,
      liveParticipations: 5,
      fanClubPosts: 10,
    ),
    tier: FanScoreTier(id: 'ultimate', label: 'Ultimate Fan'),
  );

  testWidgets(
    'CF-201: insights expandem no mesmo card; artista permanece',
    (tester) async {
      var expanded = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: FanScoreArtistCard(
                  entry: entry,
                  expanded: expanded,
                  onToggleInsights: () => setState(() => expanded = !expanded),
                ),
              );
            },
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Kheper'), findsOneWidget);
      expect(find.text('1.000'), findsOneWidget);
      expect(find.text('Insights'), findsOneWidget);
      expect(find.text('Posts FC'), findsNothing);

      await tester.tap(find.text('Insights'));
      await tester.pumpAndSettle();

      expect(find.text('Kheper'), findsOneWidget);
      expect(find.text('1.000'), findsOneWidget);
      expect(find.text('Fechar'), findsOneWidget);
      expect(find.text('Posts FC'), findsOneWidget);
      expect(find.text('Cartas'), findsOneWidget);
      expect(find.text('Membership'), findsOneWidget);

      await tester.tap(find.text('Fechar'));
      await tester.pumpAndSettle();

      expect(find.text('Insights'), findsOneWidget);
      expect(find.text('Posts FC'), findsNothing);
      expect(find.text('Kheper'), findsOneWidget);
    },
  );
}
