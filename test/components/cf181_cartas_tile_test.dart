import 'package:crowdfans/components/profile/artist_profile_letter_tile.dart';
import 'package:crowdfans/components/post/post_avatar.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/fan_letter_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CF-181: tile mostra autoria no topo com avatar', (tester) async {
    const letter = FanLetter(
      id: '1',
      artistId: 'a1',
      artistName: 'Art',
      fanDisplayName: 'Aline Duarte',
      fanHandle: 'aline',
      fanAvatarUri: '',
      votesCount: 0,
      sendsCount: 0,
      artistUpvoted: false,
      postedAt: 0,
      bodyText: 'oi',
      backgroundId: 'blush',
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: const Scaffold(
          body: SizedBox(
            width: 120,
            height: 160,
            child: ArtistProfileLetterTile(letter: letter, position: 2),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Aline Duarte'), findsOneWidget);
    expect(find.text('#2'), findsOneWidget);
    expect(find.byType(PostAvatar), findsOneWidget);

    // Print: em carta clara a autoria é escura (sem véu charcoal no topo).
    final author = tester.widget<Text>(find.text('Aline Duarte'));
    expect(author.style?.color, const Color(0xFF1C1C1E));
  });

  testWidgets('CF-181: capa escura usa autoria clara', (tester) async {
    const letter = FanLetter(
      id: '2',
      artistId: 'a1',
      artistName: 'Art',
      fanDisplayName: 'Caio Loux',
      fanHandle: 'caio',
      fanAvatarUri: '',
      votesCount: 0,
      sendsCount: 0,
      artistUpvoted: false,
      postedAt: 0,
      bodyText: 'SHOW LOTADO',
      backgroundId: 'night',
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: const Scaffold(
          body: SizedBox(
            width: 120,
            height: 160,
            child: ArtistProfileLetterTile(letter: letter, position: 1),
          ),
        ),
      ),
    );
    await tester.pump();

    final author = tester.widget<Text>(find.text('Caio Loux'));
    expect(author.style?.color, Colors.white);
  });
}
