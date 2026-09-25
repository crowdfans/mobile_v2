import 'package:crowdfans/components/post/post_share_action_tile.dart';
import 'package:crowdfans/components/post/post_share_sheet.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

FeedPost _samplePost() {
  return const FeedPost(
    id: 'post-1',
    type: PostType.text,
    author: 'Mayra',
    handle: '@mayra',
    minutesAgo: 8,
    avatarUri: '',
    text: 'Texto',
    votes: 84,
    comments: 11,
    shares: 3,
  );
}

void main() {
  testWidgets('CF-236: share sheet sem título; tiles e Compartilhar para', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: Stack(
            children: [
              PostShareSheet(
                visible: true,
                post: _samplePost(),
                onClose: () {},
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Copiar Link'), findsOneWidget);
    expect(find.text('WhatsApp'), findsOneWidget);
    expect(find.text('Stories'), findsOneWidget);
    expect(find.text('Compartilhar para...'), findsOneWidget);
    // Print CF-236: sem título “Compartilhar” (só alça + tiles).
    expect(find.text('Compartilhar'), findsNothing);
    expect(find.byIcon(Icons.ios_share), findsOneWidget);
    expect(find.byType(PostShareActionTile), findsNWidgets(3));
  });
}
