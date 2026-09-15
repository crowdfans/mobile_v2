import 'package:crowdfans/components/feed/story_live_item.dart';
import 'package:crowdfans/components/feed/story_meet_and_greet_item.dart';
import 'package:crowdfans/components/home/vote_control_bar.dart';
import 'package:crowdfans/components/post/post_card.dart';
import 'package:crowdfans/components/post/post_card_header.dart';
import 'package:crowdfans/components/post/post_rank_badge.dart';
import 'package:crowdfans/components/toolbar/image_toolbar.dart';
import 'package:crowdfans/components/toolbar/toolbar_menu_button.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:crowdfans/services/vote_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: buildCrowdFansTheme(Brightness.light),
    home: Scaffold(body: child),
  );
}

Future<VoteResult> _noopVote(VoteDirection _) async {
  return const VoteResult(id: 'p1', votes: 10, myVote: 0);
}

String? _svgAsset(WidgetTester tester, Finder finder) {
  final svg = tester.widget<SvgPicture>(finder);
  final loader = svg.bytesLoader;
  if (loader is SvgAssetLoader) {
    return loader.assetName;
  }
  return null;
}

void main() {
  group('CF-131 Feed Home UX', () {
    testWidgets('VoteControlBar neutro: borda e contagem cinza, compacto', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          VoteControlBar(votes: 12, myVote: 0, onVote: _noopVote),
        ),
      );

      final box = tester.widget<DecoratedBox>(find.byType(DecoratedBox).first);
      final decoration = box.decoration as BoxDecoration;
      final border = decoration.border! as Border;
      expect(border.top.color, AppPalette.platinum300);
      expect(border.top.width, lessThanOrEqualTo(1.5));

      final count = tester.widget<Text>(find.byKey(const Key('vote-count')));
      expect(count.style?.fontSize, lessThanOrEqualTo(12));
      expect(count.style?.color, AppPalette.platinum500);

      final size = tester.getSize(find.byType(VoteControlBar));
      expect(size.height, lessThanOrEqualTo(36));
    });

    testWidgets('VoteControlBar upvote: borda e contagem verdes (não roxo)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          VoteControlBar(votes: 12, myVote: 1, onVote: _noopVote),
        ),
      );

      final box = tester.widget<DecoratedBox>(find.byType(DecoratedBox).first);
      final decoration = box.decoration as BoxDecoration;
      final border = decoration.border! as Border;
      expect(border.top.color, AppPalette.green500);

      final count = tester.widget<Text>(find.byKey(const Key('vote-count')));
      expect(count.style?.color, AppPalette.green500);

      final upIcon = tester.widget<Icon>(
        find.descendant(
          of: find.byKey(const Key('vote-up')),
          matching: find.byType(Icon),
        ),
      );
      expect(upIcon.color, AppPalette.green500);
      expect(upIcon.color, isNot(AppPalette.purple500));
    });

    testWidgets('VoteControlBar downvote: borda e contagem vermelhas', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          VoteControlBar(votes: 12, myVote: -1, onVote: _noopVote),
        ),
      );

      final box = tester.widget<DecoratedBox>(find.byType(DecoratedBox).first);
      final decoration = box.decoration as BoxDecoration;
      final border = decoration.border! as Border;
      expect(border.top.color, AppPalette.red500);

      final count = tester.widget<Text>(find.byKey(const Key('vote-count')));
      expect(count.style?.color, AppPalette.red500);
    });

    testWidgets('StoryLiveItem: sem gap entre stroke e avatar', (tester) async {
      await tester.pumpWidget(
        _wrap(const StoryLiveItem(name: 'Live', imageUri: '')),
      );

      final ring = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(StoryLiveItem),
              matching: find.byType(Container),
            )
            .first,
      );
      expect(ring.padding, EdgeInsets.zero);
    });

    testWidgets('StoryMeetAndGreetItem: sem gap entre stroke e avatar', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const StoryMeetAndGreetItem(
            eventId: 'evt-1',
            name: 'Meet',
            imageUri: '',
          ),
        ),
      );

      final ring = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(StoryMeetAndGreetItem),
              matching: find.byType(Container),
            )
            .first,
      );
      expect(ring.padding, EdgeInsets.zero);
    });

    testWidgets('ImageToolbar: logo compacto + menu-01 + bell-03', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          ImageToolbar(onMenu: () {}, onNotifications: () {}),
        ),
      );

      final logo = tester.widget<SvgPicture>(
        find.descendant(
          of: find.byType(ImageToolbar),
          matching: find.byType(SvgPicture),
        ).at(1),
      );
      expect(logo.width, lessThanOrEqualTo(96));
      expect(logo.height, lessThanOrEqualTo(20));

      expect(
        _svgAsset(tester, find.descendant(
          of: find.byKey(const Key('home-menu')),
          matching: find.byType(SvgPicture),
        )),
        'assets/icons/General/menu-01.svg',
      );

      expect(
        _svgAsset(tester, find.descendant(
          of: find.byKey(const Key('home-notifications')),
          matching: find.byType(SvgPicture),
        )),
        'assets/icons/alerts_and_feedbacks/bell-03.svg',
      );
    });

    testWidgets('ToolbarMenuButton usa menu-01 (linhas iguais)', (tester) async {
      await tester.pumpWidget(
        _wrap(ToolbarMenuButton(onPressed: () {})),
      );
      expect(
        _svgAsset(tester, find.byType(SvgPicture)),
        'assets/icons/General/menu-01.svg',
      );
    });

    testWidgets('PostRankBadge compacto (fonte ≤10, padding curto)', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const PostRankBadge(rank: '4')));

      final text = tester.widget<Text>(find.text('#4'));
      expect(text.style?.fontSize, lessThanOrEqualTo(10));

      final padding = tester.widget<Padding>(
        find.descendant(
          of: find.byType(PostRankBadge),
          matching: find.byType(Padding),
        ),
      );
      expect(padding.padding.horizontal, lessThanOrEqualTo(12));
      expect(padding.padding.vertical, lessThanOrEqualTo(2));
    });

    testWidgets('PostCard: texto do post com fonte ≤14', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PostCard(
            post: FeedPost(
              id: 'p1',
              type: PostType.text,
              author: 'Artista',
              handle: '@artista',
              minutesAgo: 5,
              avatarUri: '',
              text: 'Texto do feed para calibração de tipografia.',
              votes: 1,
              comments: 0,
              shares: 0,
            ),
          ),
        ),
      );

      final body = tester.widget<Text>(
        find.text('Texto do feed para calibração de tipografia.'),
      );
      expect(body.style?.fontSize, lessThanOrEqualTo(14));
    });

    testWidgets('PostCardHeader: opções alinhadas ao topo', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PostCardHeader(
            displayAuthorName: 'Artista',
            displayAuthorHandle: '@artista',
            minutesAgo: 5,
            rank: '4',
            onPressOpenPostOptions: () {},
          ),
        ),
      );

      final row = tester.widget<Row>(find.byType(Row).first);
      expect(row.crossAxisAlignment, CrossAxisAlignment.start);

      final more = tester.getRect(find.byKey(const Key('post-more')));
      final name = tester.getRect(find.text('Artista'));
      expect(more.top, lessThanOrEqualTo(name.top + 2));
    });
  });
}
