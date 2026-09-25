import 'package:crowdfans/components/profile/artist_profile_fan_club_feed.dart';
import 'package:crowdfans/components/profile/artist_profile_fan_club_toolbar.dart';
import 'package:crowdfans/components/profile/me_posts_filter_chip.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
}
