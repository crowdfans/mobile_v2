import 'package:crowdfans/components/search/search_artist_rank_row.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/search_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CF-172: foto à esquerda e rank acima do nome', (tester) async {
    const artist = ArtistSearchItem(
      id: 'a1',
      name: 'Mayra',
      handle: '@mayra',
      avatarUri: '',
      memberCount: 12000,
      membersLabel: '12k membros',
      rank: 3,
      rankDelta: 1,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: SearchArtistRankRow(
            artist: artist,
            position: 3,
            onPressed: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('#3'), findsOneWidget);
    expect(find.text('Mayra'), findsOneWidget);
    // Avatar placeholder SizedBox 56 precedes text in row.
    final row = tester.widget<Row>(find.byType(Row).first);
    expect(row.children.first, isA<ClipRRect>());
  });
}
