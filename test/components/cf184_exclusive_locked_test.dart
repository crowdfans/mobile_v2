import 'package:crowdfans/components/feed/exclusive_feed_card.dart';
import 'package:crowdfans/components/feed/exclusive_feed_card_locked_content.dart';
import 'package:crowdfans/components/feed/exclusive_post_meta_row.dart';
import 'package:crowdfans/components/feed/feed_item.dart';
import 'package:crowdfans/components/profile/artist_me_tab_bar.dart';
import 'package:crowdfans/components/profile/artist_profile_exclusive_teaser.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:crowdfans/utils/exclusive_content_access.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: buildCrowdFansTheme(Brightness.light),
    home: Scaffold(body: child),
  );
}

FeedPost _kheperLockedPost() {
  return const FeedPost(
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
}

/// CF-274 — regressão dedicada CF-184 (Exclusivo bloqueado no perfil).
/// Obrigatório Gustavo: green / red / edge.
void main() {
  group('CF-184/CF-274 green — teaser único alinhado ao print', () {
    test('fixtures Kheper bloqueado; Ludmilla CF-239 intacto', () {
      expect(kUseCfTempMocks, isTrue);
      expect(CfTempMocks.useArtistExclusiveFixtures, isFalse);
      expect(
        cfTempMockArtistExclusiveForceLocked('mock-kheper', 'Kheper'),
        isTrue,
      );
      expect(
        cfTempMockArtistExclusiveForceLocked('artist-kheperrrr', 'kheperrrr'),
        isTrue,
      );
      expect(
        cfTempMockArtistExclusiveSubscribed('mock-fc-ludmilla', 'Ludmilla'),
        isTrue,
      );
      expect(
        cfTempMockArtistExclusiveForceLocked('mock-fc-ludmilla', 'Ludmilla'),
        isFalse,
      );
    });

    testWidgets(
      'sem assinatura: só teaser roxo + CTA/copy do print (sem posts)',
      (tester) async {
        final lockedPost = _kheperLockedPost();

        await tester.pumpWidget(
          _wrap(
            ListView(
              children: [
                ArtistMeTabBar(
                  selectedId: 'exclusivo',
                  onSelected: (_) {},
                ),
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
        expect(find.byType(FeedItem), findsNothing);
        expect(find.byType(ExclusiveFeedCard), findsNothing);
        expect(find.byType(ExclusiveFeedCardLockedContent), findsNothing);
      },
    );

    testWidgets('CTA Assinar Membership + dispara onSubscribe', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          ArtistProfileExclusiveTeaser(
            artistName: 'Kheper',
            onSubscribe: () => tapped = true,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Assinar Membership +'));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });

  group('CF-184/CF-274 red — bloqueio / ação negada / conteúdo não vaza', () {
    test('gate teaser-only: sem assinatura e resolved → teaser', () {
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
    });

    test(
      'posts exclusivos bloqueados: canAccessExclusivePost nega sem membership',
      () {
        final post = _kheperLockedPost();
        expect(
          canAccessExclusivePost(post, const ExclusiveAccessContext()),
          isFalse,
        );
        expect(
          canAccessExclusivePost(
            post,
            ExclusiveAccessContext(
              subscribedArtistUids: {'mock-kheper'},
            ),
          ),
          isTrue,
        );
      },
    );

    testWidgets(
      'hierarquia bloqueada: post locked NÃO lista sob o CTA do teaser',
      (tester) async {
        // Espelha artist_profile_screen: teaser-only → return teaser (sem Column de posts).
        await tester.pumpWidget(
          _wrap(
            Column(
              children: [
                ArtistProfileExclusiveTeaser(
                  artistName: 'Kheper',
                  onSubscribe: () {},
                ),
                // Redundância do app antigo (image2) — NÃO deve existir no caminho CF-184.
                if (!artistExclusiveShowsTeaserOnly(
                  subscriptionResolved: true,
                  subscribed: false,
                ))
                  FeedItem(
                    post: _kheperLockedPost(),
                    canAccessExclusive: false,
                  ),
              ],
            ),
          ),
        );
        await tester.pump();

        expect(find.textContaining('não deve aparecer'), findsNothing);
        expect(find.byType(FeedItem), findsNothing);
        expect(find.byType(ExclusiveFeedCardLockedContent), findsNothing);
        expect(find.text('Assinar Membership +'), findsOneWidget);
      },
    );
  });

  group('CF-184/CF-274 edge — chrome Home, fixtures, nome vazio/longo, rede', () {
    test('subscription ainda resolving: não mostra teaser (loading path)', () {
      expect(
        artistExclusiveShowsTeaserOnly(
          subscriptionResolved: false,
          subscribed: false,
        ),
        isFalse,
      );
    });

    test(
      'falha de rede / erro: resolved + subscribed=false → teaser (não vaza)',
      () {
        // artist_profile_screen: no erro de membership, _subscribed=false.
        expect(
          artistExclusiveShowsTeaserOnly(
            subscriptionResolved: true,
            subscribed: false,
          ),
          isTrue,
        );
      },
    );

    testWidgets(
      'não duplica chrome Home CF-235: sem Disponivel para membros no perfil',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            ArtistProfileExclusiveTeaser(
              artistName: 'Kheper',
              onSubscribe: () {},
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Disponível para membros'), findsNothing);
        expect(find.byType(ExclusivePostMetaRow), findsNothing);
        expect(find.byType(ExclusiveFeedCard), findsNothing);
        expect(find.text('Conteúdo para membros'), findsOneWidget);
        expect(find.text('Assinar Membership +'), findsOneWidget);
      },
    );

    testWidgets('artista sem nome (sem capa/display): fallback artista', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          ArtistProfileExclusiveTeaser(
            artistName: '   ',
            onSubscribe: () {},
          ),
        ),
      );
      await tester.pump();

      expect(
        find.textContaining('Assine o membership de artista'),
        findsOneWidget,
      );
      expect(find.text('Assinar Membership +'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('nome longo não quebra o teaser', (tester) async {
      const long =
          'KheperSuperFanNomeExtremamenteLongoParaQuebrarLayoutSeNaoHouverWrap';
      await tester.pumpWidget(
        _wrap(
          SingleChildScrollView(
            child: ArtistProfileExclusiveTeaser(
              artistName: long,
              onSubscribe: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.textContaining(long), findsOneWidget);
      expect(find.text('Assinar Membership +'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    test(
      'ForceLocked off para não-Kheper: Mayra/Anitta não forçam teaser CF-184',
      () {
        expect(
          cfTempMockArtistExclusiveForceLocked('mock-fc-mayra', 'Mayra'),
          isFalse,
        );
        expect(
          cfTempMockArtistExclusiveForceLocked('mock-fc-anitta', 'Anitta'),
          isFalse,
        );
      },
    );
  });
}
