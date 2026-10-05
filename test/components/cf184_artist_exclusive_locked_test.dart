import 'package:crowdfans/components/feed/exclusive_feed_card.dart';
import 'package:crowdfans/components/feed/exclusive_feed_card_locked_content.dart';
import 'package:crowdfans/components/feed/feed_item.dart';
import 'package:crowdfans/components/profile/artist_me_tab_bar.dart';
import 'package:crowdfans/components/profile/artist_profile_exclusive_teaser.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:crowdfans/utils/exclusive_content_access.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CF-184 flag + Kheper bloqueado (sem tocar Ludmilla CF-239)', () {
    expect(kUseCfTempMocks, isTrue);
    expect(CfTempMocks.useArtistExclusiveFixtures, isTrue);

    // Print CF-184 (Kheper): força teaser bloqueado.
    expect(
      cfTempMockArtistExclusiveForceLocked('mock-kheper', 'Kheper'),
      isTrue,
    );
    expect(
      cfTempMockArtistExclusiveForceLocked('artist-kheperrrr', 'kheperrrr'),
      isTrue,
    );

    // CF-239 unlocked path intacto — Ludmilla continua assinante.
    expect(
      cfTempMockArtistExclusiveSubscribed('mock-fc-ludmilla', 'Ludmilla'),
      isTrue,
    );
    expect(
      cfTempMockArtistExclusiveForceLocked('mock-fc-ludmilla', 'Ludmilla'),
      isFalse,
    );

    expect(
      artistExclusiveShowsTeaserOnly(
        subscriptionResolved: true,
        subscribed: false,
      ),
      isTrue,
    );
    expect(
      artistExclusiveShowsTeaserOnly(
        subscriptionResolved: true,
        subscribed: true,
      ),
      isFalse,
    );
    expect(
      artistExclusiveShowsTeaserOnly(
        subscriptionResolved: false,
        subscribed: false,
      ),
      isFalse,
    );
  });

  testWidgets(
    'CF-184 sem assinatura: só teaser roxo — sem posts bloqueados redundantes',
    (tester) async {
      final lockedPost = FeedPost(
        id: 'cf184-locked-should-not-show',
        type: PostType.image,
        author: 'Kheper',
        artistId: 'mock-kheper',
        handle: '@kheperrrr',
        minutesAgo: 60,
        avatarUri: '',
        text: 'Conteúdo exclusivo que não deve aparecer sob o teaser.',
        votes: 10,
        comments: 2,
        shares: 1,
        isExclusive: true,
        exclusiveLocked: true,
        imageUri: '',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: ListView(
              children: [
                ArtistMeTabBar(
                  selectedId: 'exclusivo',
                  onSelected: (_) {},
                ),
                // Hierarquia aprovada: só o card de membership.
                if (artistExclusiveShowsTeaserOnly(
                  subscriptionResolved: true,
                  subscribed: false,
                ))
                  ArtistProfileExclusiveTeaser(
                    artistName: 'Kheper',
                    onSubscribe: () {},
                  )
                else
                  FeedItem(
                    post: lockedPost,
                    canAccessExclusive: false,
                  ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Exclusivo'), findsWidgets); // tab + badge
      expect(find.text('Conteúdo para membros'), findsOneWidget);
      expect(
        find.textContaining('Assine o membership de Kheper'),
        findsOneWidget,
      );
      expect(find.text('Assinar Membership +'), findsOneWidget);
      expect(find.byType(ArtistProfileExclusiveTeaser), findsOneWidget);

      // Sem post bloqueado redundante (print app antigo / image2).
      expect(find.textContaining('não deve aparecer'), findsNothing);
      expect(find.byType(FeedItem), findsNothing);
      expect(find.byType(ExclusiveFeedCard), findsNothing);
      expect(find.byType(ExclusiveFeedCardLockedContent), findsNothing);
    },
  );

  testWidgets(
    'CF-184 teaser Ludmilla (print) — CTA branco e cópia de membership',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: ArtistProfileExclusiveTeaser(
              artistName: 'Ludmilla',
              onSubscribe: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Conteúdo para membros'), findsOneWidget);
      expect(
        find.textContaining('Assine o membership de Ludmilla'),
        findsOneWidget,
      );
      expect(find.text('Assinar Membership +'), findsOneWidget);
      expect(find.text('Exclusivo'), findsOneWidget);
    },
  );
}
