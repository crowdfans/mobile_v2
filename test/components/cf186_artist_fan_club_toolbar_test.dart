import 'package:crowdfans/components/feed/feed_item.dart';
import 'package:crowdfans/components/profile/artist_profile_fan_club_feed.dart';
import 'package:crowdfans/components/profile/artist_profile_fan_club_header.dart';
import 'package:crowdfans/components/profile/artist_profile_fan_club_toolbar.dart';
import 'package:crowdfans/components/profile/me_posts_filter_chip.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:crowdfans/services/fan_club_service.dart';
import 'package:crowdfans/utils/relative_time.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CF-186 Ludmilla fixtures: Carina vídeo + Pedro texto', () {
    expect(kUseCfTempMocks, isTrue);
    expect(CfTempMocks.useFanClubFixtures, isFalse);
    expect(cfTempMockIsLudmillaFanClubTab('mock-fc-ludmilla'), isTrue);
    expect(cfTempMockIsLudmillaFanClubTab('other-artist'), isFalse);

    final feed = cfTempMockArtistFanClubFeed('mock-fc-ludmilla');
    expect(feed.fanClub.artistName, 'Ludmilla');
    expect(feed.fanClub.name, 'Ludmilla Fã Clube');
    expect(feed.posts, hasLength(2));

    final carina = feed.posts.first;
    expect(carina.authorName, 'Carina Silva');
    expect(carina.authorHandle, 'fan/carinas');
    expect(carina.type, 'video');
    expect(carina.likesCount, 875);
    expect(carina.commentsCount, 25);
    expect(carina.sharesCount, 8);
    expect(
      carina.content,
      'Trecho curto da reação do setor inteiro quando a intro mudou ao vivo.',
    );

    final pedro = feed.posts[1];
    expect(pedro.authorName, 'Pedro Martins');
    expect(pedro.authorHandle, 'fan/pedrom');
    expect(pedro.type, 'text');
    expect(pedro.likesCount, 916);
    expect(pedro.commentsCount, 36);
    expect(pedro.sharesCount, 11);
    expect(pedro.membershipMonthsLabel, '6');
    expect(
      pedro.content,
      'Quem topa grupo só pra trocar conteúdo e organizar presença nos próximos shows?',
    );

    // CF-222 Enzo permanece intacto.
    final enzo = cfTempMockArtistFanClubFeed('mock-fc-enzo');
    expect(enzo.fanClub.artistName, 'Enzo Lima');
    expect(enzo.posts.first.authorName, 'Aline Duarte');
  });

  testWidgets(
    'CF-186: chips escuros Todos/Posts/Media + divisor após ordenação',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: ArtistProfileFanClubToolbar(
              sortPopular: false,
              filter: ArtistProfileFanClubFilter.all,
              onSortPopular: (_) {},
              onFilter: (_) {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Novos'), findsOneWidget);
      expect(find.text('Populares'), findsOneWidget);
      expect(find.text('Popularidade'), findsNothing);
      expect(find.text('Ordenar postagens por:'), findsNothing);
      expect(find.byType(MePostsFilterChip), findsNWidgets(3));
      expect(find.byType(Divider), findsOneWidget);
      expect(
        find.byKey(const Key('artist-fan-club-filter-all')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'CF-186: aba Fã Clube — cabeçalho + posts Carina/Pedro do print',
    (tester) async {
      final feed = cfTempMockArtistFanClubFeed('mock-fc-ludmilla');
      final club = feed.fanClub;
      FeedPost mapPost(FanClubFeedPost post) {
        final created = DateTime.tryParse(post.createdAt);
        final minutes = created == null
            ? 0
            : DateTime.now().difference(created).inMinutes.clamp(0, 999999);
        final months = (post.membershipMonthsLabel ?? '').trim();
        return FeedPost(
          id: post.postId,
          type: postTypeFrom(post.type),
          author: post.authorName ?? club.artistName,
          artistId: club.artistUid,
          handle: post.authorHandle ?? '',
          minutesAgo: minutes,
          avatarUri: post.authorAvatarUri ?? '',
          text: post.content,
          imageUri: post.imageUrl,
          votes: post.likesCount,
          comments: post.commentsCount,
          shares: post.sharesCount,
          membershipBadges: months.isEmpty
              ? const []
              : [MembershipBadgeInfo(label: months)],
        );
      }

      final posts = [
        for (final post in feed.posts) mapPost(post),
      ];

      await tester.binding.setSurfaceSize(const Size(400, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: ListView(
              children: [
                ArtistProfileFanClubHeader(
                  artistName: club.artistName,
                  avatarUrl: '',
                ),
                ArtistProfileFanClubToolbar(
                  sortPopular: false,
                  filter: ArtistProfileFanClubFilter.all,
                  onSortPopular: (_) {},
                  onFilter: (_) {},
                ),
                for (final post in posts)
                  FeedItem(post: post, canAccessExclusive: true),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(ArtistProfileFanClubHeader), findsOneWidget);
      expect(find.byType(ArtistProfileFanClubToolbar), findsOneWidget);
      expect(find.text('Novos'), findsOneWidget);
      expect(find.text('Todos'), findsOneWidget);
      expect(find.text('Carina Silva'), findsOneWidget);
      expect(find.text('fan/carinas'), findsOneWidget);
      expect(find.text('Pedro Martins'), findsOneWidget);
      expect(find.text('fan/pedrom'), findsOneWidget);
      expect(find.text('875'), findsOneWidget);
      expect(find.text('916'), findsOneWidget);
      expect(find.text(formatMinutesAgo(120)), findsWidgets);
      expect(find.text('Abrir fã clube'), findsNothing);
      expect(find.text('Sem membros ainda'), findsNothing);
    },
  );
}
