import 'dart:async';

import 'package:crowdfans/components/feed/stories_row.dart';
import 'package:crowdfans/components/feed/story_live_item.dart';
import 'package:crowdfans/components/feed/story_meet_and_greet_item.dart';
import 'package:crowdfans/components/home/vote_control_bar.dart';
import 'package:crowdfans/components/navigation/bottom_nav_profile_tab.dart';
import 'package:crowdfans/components/post/post_card.dart';
import 'package:crowdfans/components/post/post_card_header.dart';
import 'package:crowdfans/components/post/post_rank_badge.dart';
import 'package:crowdfans/components/toolbar/image_toolbar.dart';
import 'package:crowdfans/components/toolbar/toolbar_menu_button.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:crowdfans/models/home_feed.dart';
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

Icon _chevron(WidgetTester tester, Key key) {
  return tester.widget<Icon>(
    find.descendant(of: find.byKey(key), matching: find.byType(Icon)),
  );
}

void main() {
  // --- GREEN (print / sucesso) ---
  group('CF-131 green', () {
    testWidgets('VoteControlBar neutro: borda/contagem/setas cinza + divider', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(VoteControlBar(votes: 12, myVote: 0, onVote: _noopVote)),
      );

      final box = tester.widget<DecoratedBox>(find.byType(DecoratedBox).first);
      final decoration = box.decoration as BoxDecoration;
      final border = decoration.border! as Border;
      expect(border.top.color, AppPalette.platinum300);
      expect(border.top.width, lessThanOrEqualTo(1.5));

      final count = tester.widget<Text>(find.byKey(const Key('vote-count')));
      expect(count.style?.fontSize, lessThanOrEqualTo(12));
      expect(count.style?.color, AppPalette.platinum500);

      expect(_chevron(tester, const Key('vote-up')).color, AppPalette.platinum500);
      expect(
        _chevron(tester, const Key('vote-down')).color,
        AppPalette.platinum500,
      );
      expect(find.byKey(const Key('vote-divider')), findsOneWidget);

      final size = tester.getSize(find.byType(VoteControlBar));
      expect(size.height, lessThanOrEqualTo(36));
    });

    testWidgets(
      'VoteControlBar upvote: borda+↑+contagem verdes; ↓ cinza (não roxo)',
      (tester) async {
        await tester.pumpWidget(
          _wrap(VoteControlBar(votes: 12, myVote: 1, onVote: _noopVote)),
        );

        final box = tester.widget<DecoratedBox>(
          find.byType(DecoratedBox).first,
        );
        final decoration = box.decoration as BoxDecoration;
        final border = decoration.border! as Border;
        expect(border.top.color, AppPalette.green500);

        final count = tester.widget<Text>(find.byKey(const Key('vote-count')));
        expect(count.style?.color, AppPalette.green500);

        expect(_chevron(tester, const Key('vote-up')).color, AppPalette.green500);
        expect(
          _chevron(tester, const Key('vote-down')).color,
          AppPalette.platinum500,
        );
        expect(
          _chevron(tester, const Key('vote-up')).color,
          isNot(AppPalette.purple500),
        );
      },
    );

    testWidgets(
      'VoteControlBar downvote: borda+↓+contagem vermelhas; ↑ cinza',
      (tester) async {
        await tester.pumpWidget(
          _wrap(VoteControlBar(votes: 12, myVote: -1, onVote: _noopVote)),
        );

        final box = tester.widget<DecoratedBox>(
          find.byType(DecoratedBox).first,
        );
        final decoration = box.decoration as BoxDecoration;
        final border = decoration.border! as Border;
        expect(border.top.color, AppPalette.red500);

        final count = tester.widget<Text>(find.byKey(const Key('vote-count')));
        expect(count.style?.color, AppPalette.red500);

        expect(
          _chevron(tester, const Key('vote-up')).color,
          AppPalette.platinum500,
        );
        expect(
          _chevron(tester, const Key('vote-down')).color,
          AppPalette.red500,
        );
      },
    );

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
        _wrap(ImageToolbar(onMenu: () {}, onNotifications: () {})),
      );

      final logo = tester.widget<SvgPicture>(
        find
            .descendant(
              of: find.byType(ImageToolbar),
              matching: find.byType(SvgPicture),
            )
            .at(1),
      );
      expect(logo.width, lessThanOrEqualTo(96));
      expect(logo.height, lessThanOrEqualTo(20));

      expect(
        _svgAsset(
          tester,
          find.descendant(
            of: find.byKey(const Key('home-menu')),
            matching: find.byType(SvgPicture),
          ),
        ),
        'assets/icons/General/menu-01.svg',
      );

      expect(
        _svgAsset(
          tester,
          find.descendant(
            of: find.byKey(const Key('home-notifications')),
            matching: find.byType(SvgPicture),
          ),
        ),
        'assets/icons/alerts_and_feedbacks/bell-03.svg',
      );
    });

    testWidgets('ToolbarMenuButton usa menu-01 (linhas iguais)', (tester) async {
      await tester.pumpWidget(_wrap(ToolbarMenuButton(onPressed: () {})));
      expect(
        _svgAsset(tester, find.byType(SvgPicture)),
        'assets/icons/General/menu-01.svg',
      );
    });

    testWidgets('PostRankBadge cinza compacto (não lilás)', (tester) async {
      await tester.pumpWidget(_wrap(const PostRankBadge(rank: '4')));

      final text = tester.widget<Text>(find.text('#4'));
      expect(text.style?.fontSize, lessThanOrEqualTo(10));
      expect(text.style?.color, AppPalette.platinum600);

      final box = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byType(PostRankBadge),
          matching: find.byType(DecoratedBox),
        ),
      );
      final decoration = box.decoration as BoxDecoration;
      expect(decoration.color, AppPalette.platinum100);
      expect(decoration.color, isNot(AppPalette.purple100));

      final padding = tester.widget<Padding>(
        find.descendant(
          of: find.byType(PostRankBadge),
          matching: find.byType(Padding),
        ),
      );
      expect(padding.padding.horizontal, lessThanOrEqualTo(12));
      expect(padding.padding.vertical, lessThanOrEqualTo(2));
    });

    testWidgets('PostCard: texto do post com fonte ≤14; fundo branco', (
      tester,
    ) async {
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

      final card = tester.widget<Container>(find.byType(Container).first);
      final decoration = card.decoration as BoxDecoration?;
      expect(decoration?.color, Colors.white);
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

    testWidgets('BottomNavProfileTab: com photoUrl monta Image.network', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          SizedBox(
            height: 68,
            child: Row(
              children: [
                BottomNavProfileTab(
                  selected: true,
                  photoUrl: 'https://example.com/avatar.png',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      // Test binding devolve 400 em HTTP — consome o erro e valida o widget.
      tester.takeException();
      expect(find.byType(Image), findsOneWidget);
    });

    test(
      'Home feed demock: fixtures OFF; amostra print ainda coberta',
      () {
        expect(CfTempMocks.useHomeFeedFixtures, isFalse);
        final dto = cfTempMockHomeFeedDto(page: 1);
        expect(dto.feedPosts, isNotEmpty);
      },
    );
  });

  // --- RED (erro / vazio / falha / negado) ---
  group('CF-131 red', () {
    testWidgets('VoteControlBar: falha no onVote reverte otimista', (
      tester,
    ) async {
      final pending = Completer<VoteResult>();
      await tester.pumpWidget(
        _wrap(
          VoteControlBar(
            votes: 10,
            myVote: 0,
            onVote: (_) => pending.future,
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('vote-up')));
      await tester.pump();
      expect(find.text('11'), findsOneWidget);
      expect(_chevron(tester, const Key('vote-up')).color, AppPalette.green500);

      pending.completeError(Exception('network'));
      await tester.pump();
      expect(find.text('10'), findsOneWidget);
      expect(_chevron(tester, const Key('vote-up')).color, AppPalette.platinum500);
    });

    testWidgets('StoriesRow vazio: não renderiza lista', (tester) async {
      await tester.pumpWidget(_wrap(const StoriesRow(stories: [])));
      expect(find.byType(ListView), findsNothing);
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('PostCardHeader sem rank: não mostra badge', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PostCardHeader(
            displayAuthorName: 'Artista',
            displayAuthorHandle: '@artista',
            minutesAgo: 5,
            onPressOpenPostOptions: () {},
          ),
        ),
      );
      expect(find.byType(PostRankBadge), findsNothing);
      expect(find.textContaining('#'), findsNothing);
    });

    testWidgets('BottomNavProfileTab sem photo: fallback SVG user-01', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          SizedBox(
            height: 68,
            child: Row(
              children: [
                BottomNavProfileTab(
                  selected: false,
                  photoUrl: null,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(Image), findsNothing);
      expect(
        _svgAsset(tester, find.byType(SvgPicture)),
        'assets/images/user-01.svg',
      );
    });

    testWidgets('PostCard texto vazio: sem Text de body', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PostCard(
            post: FeedPost(
              id: 'p-empty',
              type: PostType.text,
              author: 'Artista',
              handle: '@artista',
              minutesAgo: 1,
              avatarUri: '',
              text: '   ',
              votes: 0,
              comments: 0,
              shares: 0,
            ),
          ),
        ),
      );
      expect(find.text('   '), findsNothing);
      expect(find.text('Artista'), findsOneWidget);
    });
  });

  // --- EDGE (zero, texto longo, prefixos, double-tap) ---
  group('CF-131 edge', () {
    testWidgets('VoteControlBar contagem zero permanece compacta', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(VoteControlBar(votes: 0, myVote: 0, onVote: _noopVote)),
      );
      expect(find.text('0'), findsOneWidget);
      final size = tester.getSize(find.byType(VoteControlBar));
      expect(size.height, lessThanOrEqualTo(36));
    });

    testWidgets('VoteControlBar: segundo tap enquanto submitting é ignorado', (
      tester,
    ) async {
      var calls = 0;
      await tester.pumpWidget(
        _wrap(
          VoteControlBar(
            votes: 5,
            myVote: 0,
            onVote: (_) async {
              calls++;
              await Future<void>.delayed(const Duration(milliseconds: 80));
              return const VoteResult(id: 'p1', votes: 6, myVote: 1);
            },
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('vote-up')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('vote-up')));
      await tester.pump();
      expect(calls, 1);
      await tester.pump(const Duration(milliseconds: 100));
      expect(calls, 1);
    });

    testWidgets('PostRankBadge: rank já com # não duplica', (tester) async {
      await tester.pumpWidget(_wrap(const PostRankBadge(rank: '#3')));
      expect(find.text('#3'), findsOneWidget);
      expect(find.text('##3'), findsNothing);
    });

    testWidgets('PostCard: texto longo mantém fonte ≤14 sem overflow exception', (
      tester,
    ) async {
      final long = 'teoria ' * 40;
      await tester.pumpWidget(
        _wrap(
          SingleChildScrollView(
            child: PostCard(
              post: FeedPost(
                id: 'p-long',
                type: PostType.text,
                author: 'Mayra',
                handle: '@mayra',
                minutesAgo: 8,
                avatarUri: '',
                text: long,
                votes: 84,
                comments: 11,
                shares: 3,
                rank: '3',
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      final body = tester.widget<Text>(find.text(long));
      expect(body.style?.fontSize, lessThanOrEqualTo(14));
      expect(find.byType(PostRankBadge), findsOneWidget);
    });

    testWidgets('StoriesRow: meetandgreet usa anel verde (não live)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          StoriesRow(
            stories: const [
              StoryItem(
                id: 's1',
                name: 'TINN',
                handle: '@tinn',
                imageUri: '',
                featureType: 'meetandgreet',
                eventId: 'evt-1',
              ),
            ],
          ),
        ),
      );
      expect(find.byType(StoryMeetAndGreetItem), findsOneWidget);
      expect(find.byType(StoryLiveItem), findsNothing);
    });
  });
}
