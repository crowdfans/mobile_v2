import 'package:crowdfans/components/fan_clubs/fan_club_artist_chip.dart';
import 'package:crowdfans/components/fan_clubs/fan_clubs_feed_filters.dart';
import 'package:crowdfans/components/fan_clubs/fan_clubs_feed_header.dart';
import 'package:crowdfans/components/home/scroll_to_top_fab.dart';
import 'package:crowdfans/components/profile/me_posts_filter_chip.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/services/community_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: buildCrowdFansTheme(Brightness.light),
    home: Scaffold(body: child),
  );
}

FanClubsFeedHeader _header({
  bool sortPopular = true,
  bool filterAll = true,
  bool filterPosts = false,
  bool filterMedia = false,
  VoidCallback? onFilterPosts,
  VoidCallback? onFilterMedia,
  VoidCallback? onSortNew,
}) {
  return FanClubsFeedHeader(
    sortPopular: sortPopular,
    filterAll: filterAll,
    filterPosts: filterPosts,
    filterMedia: filterMedia,
    onOpenMenu: () {},
    onOpenSearch: () {},
    onSortPopular: () {},
    onSortNew: onSortNew ?? () {},
    onFilterAll: () {},
    onFilterPosts: onFilterPosts ?? () {},
    onFilterMedia: onFilterMedia ?? () {},
  );
}

CommunityPost _post({
  required String id,
  required String type,
  required int votes,
  int minutesAgo = 60,
  String? imageUri,
}) {
  return CommunityPost(
    id: id,
    type: type,
    author: 'Autor $id',
    handle: 'fan/$id',
    minutesAgo: minutesAgo,
    avatarUri: '',
    text: 'texto $id',
    votes: votes,
    comments: 0,
    shares: 0,
    imageUri: imageUri,
  );
}

/// CF-178 — Feed fã-clubes filtros (print Todos/Posts/Media, API real).
/// Obrigatório Gustavo: green / red / edge.
void main() {
  group('CF-178 green — chrome print + filtro util', () {
    testWidgets(
      'Popularidade/Novos + Todos/Posts/Media + Divider + underline',
      (tester) async {
        await tester.pumpWidget(_wrap(_header()));
        await tester.pump();

        expect(find.text('Postagens dos Fã Clubes'), findsOneWidget);
        expect(find.text('Ordenar postagens por:'), findsOneWidget);
        expect(find.text('Popularidade'), findsOneWidget);
        expect(find.text('Novos'), findsOneWidget);
        expect(find.byKey(const Key('fan-clubs-filter-all')), findsOneWidget);
        expect(find.byKey(const Key('fan-clubs-filter-posts')), findsOneWidget);
        expect(find.byKey(const Key('fan-clubs-filter-media')), findsOneWidget);
        expect(find.byType(MePostsFilterChip), findsNWidgets(3));
        expect(find.byType(Divider), findsOneWidget);
        expect(find.byType(IntrinsicWidth), findsWidgets);
      },
    );

    test('Popularidade ordena por votos desc; Novos por minutesAgo asc', () {
      final posts = [
        _post(id: 'a', type: 'text', votes: 10, minutesAgo: 5),
        _post(id: 'b', type: 'text', votes: 100, minutesAgo: 90),
        _post(id: 'c', type: 'text', votes: 50, minutesAgo: 30),
      ];

      final byPopular = fanClubsVisiblePosts(
        posts: posts,
        sortPopular: true,
        filter: FanClubsContentFilter.all,
      );
      expect(byPopular.map((p) => p.id), ['b', 'c', 'a']);

      final byNew = fanClubsVisiblePosts(
        posts: posts,
        sortPopular: false,
        filter: FanClubsContentFilter.all,
      );
      expect(byNew.map((p) => p.id), ['a', 'c', 'b']);
    });

    test('Posts vs Media alinhados ao print (carrossel = mídia)', () {
      final posts = [
        _post(id: 'text', type: 'text', votes: 1039),
        _post(
          id: 'carousel',
          type: 'carousel',
          votes: 412,
          imageUri: 'https://example.com/x.jpg',
        ),
        _post(id: 'img', type: 'image', votes: 1),
      ];

      final onlyPosts = fanClubsVisiblePosts(
        posts: posts,
        sortPopular: true,
        filter: FanClubsContentFilter.posts,
      );
      expect(onlyPosts.map((p) => p.id), ['text']);

      final onlyMedia = fanClubsVisiblePosts(
        posts: posts,
        sortPopular: true,
        filter: FanClubsContentFilter.media,
      );
      expect(onlyMedia.map((p) => p.id), ['carousel', 'img']);
    });

    test('fixtures do print (Felipe Rhy + Laís Costa) documentam image1', () {
      final posts = Cf178FanClubsFeedMock.posts();
      expect(posts, hasLength(2));
      expect(posts.first.author, 'Felipe Rhy');
      expect(posts.first.handle, 'fan/thiagok');
      expect(posts.first.votes, 1039);
      expect(posts.last.author, 'Laís Costa');
      expect(posts.last.type, 'carousel');
      expect(isFanClubsMediaPost(posts.last), isTrue);
      expect(isFanClubsMediaPost(posts.first), isFalse);
    });
  });

  group('CF-178 red — sem chips de artista; mocks off; vazio sem inventar', () {
    testWidgets('header sem FanClubArtistChip (Vic/Mayra/Gus Art)', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(_header()));
      await tester.pump();

      expect(find.byType(FanClubArtistChip), findsNothing);
      expect(find.text('Vic Art'), findsNothing);
      expect(find.text('Mayra Art'), findsNothing);
      expect(find.text('Gus Art'), findsNothing);
      expect(find.byType(MePostsFilterChip), findsNWidgets(3));
    });

    test('kUseCf178FanClubsFeedMocks=false → API vazia não vira fixture', () {
      expect(kUseCf178FanClubsFeedMocks, isFalse);
      expect(shouldUseCf178FanClubsFeedFixtures(const []), isFalse);
      expect(
        shouldUseCf178FanClubsFeedFixtures(Cf178FanClubsFeedMock.posts()),
        isFalse,
      );
    });

    test('filtro Posts com só mídia → lista vazia (sem contagem inventada)', () {
      final posts = [
        _post(id: 'm1', type: 'image', votes: 9),
        _post(id: 'm2', type: 'video', votes: 3),
      ];
      final visible = fanClubsVisiblePosts(
        posts: posts,
        sortPopular: true,
        filter: FanClubsContentFilter.posts,
      );
      expect(visible, isEmpty);
      expect(
        fanClubsEmptyMessage(hasArtists: true),
        'Nenhum post na comunidade ainda.',
      );
    });

    testWidgets('FAB oculto no estado inicial (não obrigatório sem rolagem)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const Stack(
            children: [
              SizedBox.expand(),
              ScrollToTopFab(visible: false, onPressed: _noop),
            ],
          ),
        ),
      );
      await tester.pump();

      final fab = tester.widget<ScrollToTopFab>(find.byType(ScrollToTopFab));
      expect(fab.visible, isFalse);
    });
  });

  group('CF-178 edge — troca de chips, FAB, imageUri, sem artistas', () {
    testWidgets('tap Posts/Media troca seleção do chrome', (tester) async {
      var filter = FanClubsContentFilter.all;

      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: _header(
                  filterAll: filter == FanClubsContentFilter.all,
                  filterPosts: filter == FanClubsContentFilter.posts,
                  filterMedia: filter == FanClubsContentFilter.media,
                  onFilterPosts: () {
                    setState(() => filter = FanClubsContentFilter.posts);
                  },
                  onFilterMedia: () {
                    setState(() => filter = FanClubsContentFilter.media);
                  },
                ),
              );
            },
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key('fan-clubs-filter-posts')));
      await tester.pump();
      expect(filter, FanClubsContentFilter.posts);

      await tester.tap(find.byKey(const Key('fan-clubs-filter-media')));
      await tester.pump();
      expect(filter, FanClubsContentFilter.media);
    });

    testWidgets('FAB visível quando scrolled (image2)', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const Stack(
            children: [
              SizedBox.expand(),
              ScrollToTopFab(visible: true, onPressed: _noop),
            ],
          ),
        ),
      );
      await tester.pump();

      final fab = tester.widget<ScrollToTopFab>(find.byType(ScrollToTopFab));
      expect(fab.visible, isTrue);
      expect(find.byIcon(Icons.keyboard_arrow_up_rounded), findsOneWidget);
    });

    test('texto com imageUri conta como Media; zero posts + sem artistas', () {
      final withUri = _post(
        id: 'uri',
        type: 'text',
        votes: 1,
        imageUri: ' https://cdn.example/a.jpg ',
      );
      expect(isFanClubsMediaPost(withUri), isTrue);

      final blankUri = _post(id: 'blank', type: 'text', votes: 1, imageUri: '  ');
      expect(isFanClubsMediaPost(blankUri), isFalse);

      expect(
        fanClubsEmptyMessage(hasArtists: false),
        'Siga artistas para ver posts da comunidade aqui.',
      );
    });

    testWidgets('rótulos longos do header não quebram IntrinsicWidth', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: 320,
            child: _header(),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('Popularidade'), findsOneWidget);
      expect(find.byType(IntrinsicWidth), findsWidgets);
    });
  });
}

void _noop() {}
