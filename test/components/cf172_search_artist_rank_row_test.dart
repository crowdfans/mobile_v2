import 'package:crowdfans/components/search/search_artist_rank_row.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/search_service.dart';
import 'package:flutter/material.dart';
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
    // Print: badge à esquerda do avatar.
    final badge = tester.getTopLeft(find.text('#3'));
    final clip = tester.getTopLeft(find.byType(ClipRRect).first);
    expect(badge.dx, lessThan(clip.dx));
    // Sem rótulo textual de tendência na linha (só o círculo).
    expect(find.text('subiu'), findsNothing);
    expect(find.text('estável'), findsNothing);
  });
}
