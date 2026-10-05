import 'package:crowdfans/models/feed_post.dart';
import 'package:crowdfans/utils/exclusive_content_access.dart';
import 'package:flutter_test/flutter_test.dart';

/// CF-272: Fã Clube base = follow; membership só para perks.
void main() {
  group('canAccessFanClubBase', () {
    test('follower-only tem acesso base', () {
      expect(
        canAccessFanClubBase(
          isFollowing: true,
          isMember: false,
          isExpelled: false,
        ),
        isTrue,
      );
    });

    test('member-only tem acesso base', () {
      expect(
        canAccessFanClubBase(
          isFollowing: false,
          isMember: true,
          isExpelled: false,
        ),
        isTrue,
      );
    });

    test('outsider sem follow/membership não tem acesso', () {
      expect(
        canAccessFanClubBase(
          isFollowing: false,
          isMember: false,
          isExpelled: false,
        ),
        isFalse,
      );
    });

    test('expelled follower não tem acesso', () {
      expect(
        canAccessFanClubBase(
          isFollowing: true,
          isMember: false,
          isExpelled: true,
        ),
        isFalse,
      );
    });

    test('owner tem acesso mesmo sem follow', () {
      expect(
        canAccessFanClubBase(
          isFollowing: false,
          isMember: false,
          isExpelled: false,
          isOwner: true,
        ),
        isTrue,
      );
    });
  });

  group('canAccessExclusivePost stays membership perk', () {
    test('follower context sem subscription não destrava exclusivo', () {
      final post = FeedPost(
        id: 'p1',
        type: PostType.text,
        author: 'Artista',
        handle: 'artist/a',
        minutesAgo: 1,
        avatarUri: '',
        text: 'exclusivo',
        votes: 0,
        comments: 0,
        shares: 0,
        artistId: 'artist-1',
        isExclusive: true,
        exclusiveLocked: true,
      );
      expect(
        canAccessExclusivePost(
          post,
          const ExclusiveAccessContext(),
        ),
        isFalse,
      );
      expect(
        canAccessExclusivePost(
          post,
          const ExclusiveAccessContext(
            subscribedArtistUids: {'artist-1'},
          ),
        ),
        isTrue,
      );
    });
  });
}
