import 'package:crowdfans/components/feed/exclusive_feed_card.dart';
import 'package:crowdfans/components/feed/feed_item.dart';
import 'package:crowdfans/components/post/post_card.dart';
import 'package:crowdfans/components/profile/artist_me_tab_bar.dart';
import 'package:crowdfans/components/profile/artist_profile_compact_header.dart';
import 'package:crowdfans/components/profile/artist_profile_exclusive_teaser.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/utils/relative_time.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CF-239 flag + fixtures Ludmilla assinante', () {
    expect(kUseCfTempMocks, isTrue);
    expect(CfTempMocks.useArtistExclusiveFixtures, isTrue);
    expect(
      cfTempMockArtistExclusiveSubscribed('mock-fc-ludmilla', 'Ludmilla'),
      isTrue,
    );
    expect(
      cfTempMockArtistExclusiveSubscribed('other-artist', 'Mayra'),
      isFalse,
    );

    final posts = cfTempMockLudmillaExclusivePosts();
    expect(posts, hasLength(2));
    expect(posts.every((p) => p.isExclusive && !p.exclusiveLocked), isTrue);
    expect(posts.first.author, 'Ludmilla');
    expect(posts.first.handle, '@ludmilla');
    expect(posts.first.minutesAgo, 25);
    expect(formatMinutesAgo(posts.first.minutesAgo), '25 minutos atrás');
    expect(
      posts.first.text,
      'Hoje foi estúdio, prova de look e conversa longa com a equipe. '
      'Resolvi largar tudo aqui.',
    );
    expect(posts.first.votes, 123);
    expect(posts.first.comments, 26);
    expect(posts.first.shares, 9);
    expect(posts.first.carouselUris.length, greaterThanOrEqualTo(2));

    expect(posts[1].text, 'Visual novo, teste de luz e foto roubada de bastidor.');
    expect(formatMinutesAgo(posts[1].minutesAgo), '1 hora atrás');
  });

  testWidgets(
    'CF-239 assinante: anatomia de post comum sem badge/CTA de compra',
    (tester) async {
      final post = cfTempMockLudmillaExclusivePosts().first;

      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: ListView(
              children: [
                ArtistProfileCompactHeader(
                  displayName: 'Ludmilla',
                  handle: '@ludmilla',
                  avatarUrl: '',
                  onBack: () {},
                  onMore: () {},
                ),
                ArtistMeTabBar(
                  selectedId: 'exclusivo',
                  onSelected: (_) {},
                ),
                FeedItem(
                  post: post,
                  canAccessExclusive: true,
                  plainExclusiveWhenUnlocked: true,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Ludmilla'), findsWidgets);
      expect(find.text('@ludmilla'), findsWidgets);
      expect(find.text('Exclusivo'), findsOneWidget); // tab label only
      expect(find.text('25 minutos atrás'), findsOneWidget);
      expect(
        find.textContaining('Hoje foi estúdio, prova de look'),
        findsOneWidget,
      );
      expect(find.text('123'), findsOneWidget);
      expect(find.text('26'), findsOneWidget);
      expect(find.text('9'), findsOneWidget);

      // Sem chrome de exclusivo Home (CF-235) nem teaser bloqueado (CF-184).
      expect(find.text('Disponível para membros'), findsNothing);
      expect(find.text('Assinar Membership +'), findsNothing);
      expect(find.textContaining('Assine o membership'), findsNothing);
      expect(find.byType(ArtistProfileExclusiveTeaser), findsNothing);
      expect(find.byType(ExclusiveFeedCard), findsNothing);
      expect(find.byType(PostCard), findsOneWidget);
    },
  );

  testWidgets(
    'CF-184 intacto: sem assinatura o teaser ainda anuncia membership',
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

      expect(find.text('Assinar Membership +'), findsOneWidget);
      expect(find.textContaining('Assine o membership de Ludmilla'), findsOneWidget);
    },
  );
}
