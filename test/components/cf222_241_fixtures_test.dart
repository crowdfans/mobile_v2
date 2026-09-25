import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CF-222…230 fan club fixtures: Enzo / Felipe / Laís', () {
    final enzo = cfTempMockArtistFanClubFeed('mock-fc-enzo');
    expect(enzo.fanClub.artistName, 'Enzo Lima');
    expect(enzo.fanClub.memberCount, 11841);
    expect(enzo.fanClub.moderators.map((m) => m.displayName), [
      'Aline Duarte',
      'Maria Eduarda',
      'Lari Rocha',
    ]);
    expect(enzo.posts.first.authorName, 'Aline Duarte');
    expect(enzo.posts.first.authorHandle, 'fan/alineduarte');
    expect(enzo.posts.first.membershipMonthsLabel, '3');
    expect(enzo.posts.first.carouselUris.length, greaterThanOrEqualTo(2));

    final expelled = cfTempMockArtistFanClubFeed('mock-fc-felipe-rhy');
    expect(expelled.fanClub.viewerIsExpelled, isTrue);
    expect(expelled.fanClub.viewerExpulsionReason, cfTempMockExpulsionReason);
    expect(expelled.fanClub.memberCount, 6972);

    final warning = cfTempMockArtistFanClubFeed('mock-fc-lais');
    expect(warning.fanClub.viewerActiveStrikesCount, greaterThan(0));
    expect(warning.fanClub.viewerStrikeRemainingChances, 2);
    expect(warning.fanClub.viewerLatestStrikeReason, cfTempMockStrikeReason);
  });

  test('CF-232/233/235 home feed fixtures', () {
    final posts = cfTempMockHomeFeedPosts();
    expect(posts.any((p) => p.author == 'Banda Uelo' && p.type == PostType.video),
        isTrue);
    expect(
      posts.any(
        (p) =>
            p.type == PostType.carousel && p.carouselUris.length >= 3,
      ),
      isTrue,
    );
    final exclusive = posts.firstWhere((p) => p.isExclusive);
    expect(exclusive.author, 'Mayra');
    expect(exclusive.exclusiveLocked, isFalse);
    expect(exclusive.rank, '#3');
  });

  test('CF-237 selector + CF-240 search L + CF-241 Ludmilla ranking', () {
    final clubs = cfTempMockFanClubSelectorArtists();
    expect(clubs.map((c) => c.name).toList(), [
      'Mayra',
      'Marinhos',
      'Banda Uelo',
      'Enzo Lima',
      'Ludmilla',
      'Anitta',
    ]);

    final search = cfTempMockSearchArtists('L')!;
    expect(search.first.name, 'Ludmilla');
    expect(search.first.rank, 1);
    expect(search.length, 5);

    final rank = cfTempMockRankingArtists(kind: 'fan-clubs').first;
    expect(rank.name, 'Ludmilla');
    expect(rank.weeksInRanking, 11);
    expect(rank.peakRank, 1);
    expect(rank.previousRank, 2);
  });

  test('CF-239 Ludmilla exclusive subscribed fixtures', () {
    expect(
      cfTempMockArtistExclusiveSubscribed('mock-fc-ludmilla', 'Ludmilla'),
      isTrue,
    );
    final posts = cfTempMockLudmillaExclusivePosts();
    expect(posts.every((p) => p.isExclusive && !p.exclusiveLocked), isTrue);
    expect(posts.first.carouselUris.length, greaterThanOrEqualTo(2));
  });
}
