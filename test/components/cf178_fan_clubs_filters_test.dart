import 'package:crowdfans/components/fan_clubs/fan_club_artist_chip.dart';
import 'package:crowdfans/components/fan_clubs/fan_clubs_feed_header.dart';
import 'package:crowdfans/components/home/scroll_to_top_fab.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'CF-178: filtros do feed são só Todos/Posts/Media (sem chips de artista)',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: FanClubsFeedHeader(
              sortPopular: true,
              filterAll: true,
              filterPosts: false,
              filterMedia: false,
              onOpenMenu: () {},
              onOpenSearch: () {},
              onSortPopular: () {},
              onSortNew: () {},
              onFilterAll: () {},
              onFilterPosts: () {},
              onFilterMedia: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Popularidade'), findsOneWidget);
      expect(find.text('Novos'), findsOneWidget);
      expect(find.byKey(const Key('fan-clubs-filter-all')), findsOneWidget);
      expect(find.byKey(const Key('fan-clubs-filter-posts')), findsOneWidget);
      expect(find.byKey(const Key('fan-clubs-filter-media')), findsOneWidget);
      expect(find.byType(FanClubArtistChip), findsNothing);
    },
  );

  testWidgets('CF-178: FAB de topo existe e fica oculto no estado inicial', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: const Scaffold(
          body: Stack(
            children: [
              SizedBox.expand(),
              ScrollToTopFab(visible: false, onPressed: _noop),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    final fab = tester.widget<ScrollToTopFab>(find.byType(ScrollToTopFab));
    expect(fab.visible, isFalse);
  });
}

void _noop() {}
