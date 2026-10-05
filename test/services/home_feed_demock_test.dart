import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:crowdfans/models/home_feed.dart';
import 'package:crowdfans/screens/home/home_screen.dart';
import 'package:flutter_test/flutter_test.dart';

/// Demock `useHomeFeedFixtures` — CF-175 / CF-232…236.
/// Green = API shape + helpers; red = vazio/erro; edge = page>1 / video fallback.
void main() {
  group('home feed demock green', () {
    test('flag off — HomeFeedService usa GET /api/v1/home', () {
      expect(CfTempMocks.useHomeFeedFixtures, isFalse);
      expect(kUseCfTempMocks, isTrue);
    });

    test('fromJson parseia payload real de GET /home', () {
      final dto = HomeFeedDto.fromJson({
        'feedPosts': [
          {
            'id': 'p1',
            'type': 'text',
            'author': 'Demock Home Artist',
            'handle': 'artist/demock',
            'minutesAgo': 1,
            'avatarUri': '',
            'text': 'Demock home text post',
            'votes': 0,
            'comments': 0,
            'shares': 0,
            'isExclusive': false,
            'exclusiveLocked': false,
          },
          {
            'id': 'p2',
            'type': 'text',
            'author': 'Demock Home Artist',
            'handle': 'artist/demock',
            'minutesAgo': 1,
            'avatarUri': '',
            'text': 'Demock exclusive',
            'votes': 0,
            'comments': 0,
            'shares': 0,
            'isExclusive': true,
            'exclusiveLocked': true,
          },
          {
            'id': 'p3',
            'type': 'video',
            'author': 'Demock Home Artist',
            'handle': 'artist/demock',
            'minutesAgo': 0,
            'avatarUri': '',
            'text': 'Demock video',
            'imageUri':
                'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
            'votes': 0,
            'comments': 0,
            'shares': 0,
          },
        ],
        'stories': <Object>[],
        'followedArtists': [
          {
            'id': 'a1',
            'username': 'Demock Home Artist',
            'avatarUrl': 'https://example.com/a.jpg',
          },
        ],
        'hasMore': false,
      });

      expect(dto.feedPosts, hasLength(3));
      expect(dto.followedArtists, hasLength(1));
      expect(dto.hasMore, isFalse);

      final locked = dto.feedPosts.firstWhere((p) => p.id == 'p2');
      expect(locked.isExclusive, isTrue);
      expect(locked.exclusiveLocked, isTrue);

      final video = dto.feedPosts.firstWhere((p) => p.id == 'p3');
      expect(video.type, PostType.video);
      expect(video.videoUri, contains('BigBuckBunny'));
    });

    test('amostra print CF-175/232…236 permanece nos helpers', () {
      final posts = cfTempMockHomeFeedPosts();
      expect(posts.any((p) => p.id == 'cf175-kheper-locked'), isTrue);
      expect(posts.any((p) => p.id == 'cf232-uelo-video'), isTrue);
      expect(posts.any((p) => p.id == 'cf233-ponzanelli-carousel'), isTrue);
      expect(posts.any((p) => p.id == 'cf235-mayra-exclusive'), isTrue);
      expect(posts.any((p) => p.id == 'cf236-mayra-share'), isTrue);
    });
  });

  group('home feed demock red', () {
    test('feed vazio — DTO sem posts', () {
      final dto = HomeFeedDto.fromJson({
        'feedPosts': <Object>[],
        'stories': <Object>[],
        'hasMore': false,
      });
      expect(dto.feedPosts, isEmpty);
      expect(artistHomePosts(dto.feedPosts), isEmpty);
    });

    test('payload inválido / ausente não quebra fromJson', () {
      final dto = HomeFeedDto.fromJson(null);
      expect(dto.feedPosts, isEmpty);
      expect(dto.stories, isEmpty);
      expect(dto.followedArtists, isEmpty);
    });

    test('exclusivo bloqueado sem membership (membershipLocked edge)', () {
      final post = FeedPost.fromJson({
        'id': 'locked',
        'type': 'membership',
        'author': 'Kheper',
        'handle': '@kheperrrr',
        'minutesAgo': 19,
        'avatarUri': '',
        'text': '',
        'votes': 110,
        'comments': 21,
        'shares': 7,
        'isExclusive': true,
        'exclusiveLocked': true,
        'membershipLocked': true,
      });
      expect(post.exclusiveLocked, isTrue);
      expect(post.membershipLocked, isTrue);
      expect(post.type, PostType.membership);
    });
  });

  group('home feed demock edge', () {
    test('page > 1 do helper print fica vazio (não mascara API)', () {
      final page2 = cfTempMockHomeFeedDto(page: 2);
      expect(page2.feedPosts, isEmpty);
      expect(page2.hasMore, isFalse);
    });

    test('carousel sem carouselUris usa imageUri único no PostMedia path', () {
      final post = FeedPost.fromJson({
        'id': 'car',
        'type': 'carousel',
        'author': 'Ponzanelli',
        'handle': '@ponzanelli',
        'minutesAgo': 60,
        'avatarUri': '',
        'text': 'backstage',
        'imageUri': 'https://example.com/only.jpg',
        'votes': 1,
        'comments': 0,
        'shares': 0,
      });
      expect(post.type, PostType.carousel);
      expect(post.carouselUris, isEmpty);
      expect(post.imageUri, 'https://example.com/only.jpg');
    });

    test('pull-to-refresh physics permanece AlwaysScrollable (lista curta)', () {
      expect(homeFeedScrollPhysics.toString(), contains('AlwaysScrollable'));
    });

    test('artistHomePosts: sem artistId não esvazia feed de artistas', () {
      final posts = [
        FeedPost.fromJson({
          'id': 'a',
          'type': 'text',
          'author': 'X',
          'handle': 'artist/x',
          'minutesAgo': 0,
          'avatarUri': '',
          'text': 'hi',
          'votes': 0,
          'comments': 0,
          'shares': 0,
        }),
      ];
      expect(artistHomePosts(posts), hasLength(1));
    });
  });
}
