import 'package:crowdfans/components/fan_club/fan_club_community_cover.dart';
import 'package:crowdfans/components/fan_club/fan_club_community_toolbar.dart';
import 'package:crowdfans/components/post/my_post_row.dart';
import 'package:crowdfans/components/profile/artist_profile_public_cover.dart';
import 'package:crowdfans/components/search/search_artist_rank_row.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:crowdfans/services/post_service.dart';
import 'package:crowdfans/services/search_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

bool _isSvgAsset(Widget widget, String assetName) {
  if (widget is! SvgPicture) {
    return false;
  }
  final loader = widget.bytesLoader;
  return loader is SvgAssetLoader && loader.assetName == assetName;
}

Finder svgAsset(String assetName) {
  return find.byWidgetPredicate((widget) => _isSvgAsset(widget, assetName));
}

void main() {
  const horizontal = 'assets/icons/General/dots-horizontal.svg';
  const vertical = 'assets/icons/General/dots-vertical.svg';

  testWidgets('artist_profile_public_cover usa dots-horizontal.svg', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ArtistProfilePublicCover(
            imageUrl: '',
            displayName: 'Artista',
            membersLabel: '10 membros',
            following: false,
            busy: false,
            onBack: () {},
            onMore: () {},
            onToggleFollow: () {},
          ),
        ),
      ),
    );

    expect(svgAsset(horizontal), findsOneWidget);
    expect(find.byIcon(Icons.more_horiz), findsNothing);
    expect(find.byIcon(Icons.more_vert), findsNothing);
  });

  testWidgets('fan_club_community_cover usa dots-horizontal.svg', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FanClubCommunityCover(
            imageUrl: '',
            onBack: () {},
            onSearch: () {},
            onMore: () {},
          ),
        ),
      ),
    );

    expect(svgAsset(horizontal), findsOneWidget);
    expect(find.byIcon(Icons.more_horiz), findsNothing);
  });

  testWidgets('fan_club_community_toolbar usa dots-horizontal.svg', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FanClubCommunityToolbar(
            artistName: 'Artista',
            avatarUrl: '',
            onBack: () {},
            onMore: () {},
          ),
        ),
      ),
    );

    expect(svgAsset(horizontal), findsOneWidget);
    expect(find.byIcon(Icons.more_horiz), findsNothing);
  });

  testWidgets('search_artist_rank_row usa dots-vertical.svg', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SearchArtistRankRow(
            artist: const ArtistSearchItem(
              id: 'a1',
              name: 'Artista',
              handle: 'artista',
              avatarUri: '',
              memberCount: 10,
              membersLabel: '10',
              rank: 1,
            ),
            onPressed: () {},
            onPressMore: () {},
            position: 1,
          ),
        ),
      ),
    );

    expect(svgAsset(vertical), findsOneWidget);
    expect(find.byIcon(Icons.more_vert), findsNothing);
  });

  testWidgets('my_post_row usa dots-vertical.svg', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MyPostRow(
            post: UserPost(
              id: 'p1',
              userId: 'u1',
              type: PostType.text,
              text: 'Olá',
              createdAt: DateTime.now().toUtc().toIso8601String(),
              updatedAt: DateTime.now().toUtc().toIso8601String(),
            ),
            onOpenMenu: () {},
          ),
        ),
      ),
    );

    expect(svgAsset(vertical), findsOneWidget);
    expect(find.byIcon(Icons.more_vert), findsNothing);
  });
}

