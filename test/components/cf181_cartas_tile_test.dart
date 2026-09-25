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
  });
}
