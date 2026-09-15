import 'package:crowdfans/components/feed/story_meet_and_greet_item.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/home_feed.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  test('StoryItem.fromJson lê eventId do meet-event', () {
    final story = StoryItem.fromJson({
      'id': '11111111-1111-1111-1111-111111111111',
      'eventId': '11111111-1111-1111-1111-111111111111',
      'name': 'Ana',
      'handle': 'artist/ana',
      'imageUri': 'https://cdn/a.jpg',
      'featureType': 'meetandgreet',
    });

    expect(story.eventId, '11111111-1111-1111-1111-111111111111');
    expect(story.featureType, 'meetandgreet');
  });

  test('Pages.meetLobbyOf aponta para o lobby do evento', () {
    expect(
      Pages.meetLobbyOf(
        '11111111-1111-1111-1111-111111111111',
        name: 'Ana',
        avatarUrl: 'https://cdn/a.jpg',
      ),
      '/meet/events/11111111-1111-1111-1111-111111111111'
          '?name=Ana&avatarUrl=${Uri.encodeQueryComponent('https://cdn/a.jpg')}',
    );
  });

  testWidgets('story meetandgreet abre lobby do evento, não Meet 1:1', (
    tester,
  ) async {
    String? opened;
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => Scaffold(
            body: StoryMeetAndGreetItem(
              eventId: '11111111-1111-1111-1111-111111111111',
              name: 'Ana',
              imageUri: 'https://cdn/a.jpg',
            ),
          ),
        ),
        GoRoute(
          path: Pages.meetLobby,
          builder: (context, state) {
            opened = state.matchedLocation;
            return const Scaffold(body: Text('lobby'));
          },
        ),
        GoRoute(
          path: Pages.meetRequest,
          builder: (context, state) {
            opened = state.uri.toString();
            return const Scaffold(body: Text('request'));
          },
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        theme: buildCrowdFansTheme(Brightness.light),
        routerConfig: router,
      ),
    );
    await tester.pump();
    await tester.tap(find.byType(InkWell));
    await tester.pumpAndSettle();

    expect(opened, contains('/meet/events/11111111-1111-1111-1111-111111111111'));
    expect(opened, isNot(contains('/meet/request')));
    expect(find.text('lobby'), findsOneWidget);
    expect(find.text('request'), findsNothing);
  });
}
