import 'package:crowdfans/components/fan_club/fan_club_community_hero.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CF-222 hero do fã-clube com membros e favorito acessível', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: FanClubCommunityHero(
            artistName: 'Enzo Lima',
            memberCount: 11841,
            isFavorite: true,
            onToggleFavorite: () {},
            onOpenArtist: () {},
            onAbout: () {},
            onRules: () {},
          ),
        ),
      ),
    );

    expect(find.textContaining('Enzo Lima'), findsOneWidget);
    expect(find.textContaining('Fã Clube'), findsOneWidget);
    expect(find.textContaining('11.841'), findsOneWidget);
    expect(find.text('Ver mais'), findsOneWidget);
    expect(find.text('Regras'), findsOneWidget);
    expect(find.byTooltip('Remover dos favoritos'), findsOneWidget);
  });
}
