import 'package:crowdfans/components/profile/artist_profile_cover_cta.dart';
import 'package:crowdfans/components/profile/artist_profile_public_cover.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CF-185 flag + fixtures capa/CTA por artista', () {
    expect(kUseCfTempMocks, isTrue);
    expect(kUseCf185ArtistFeedMocks, isTrue);

    final lud = Cf185ArtistFeedFixtures.ludmilla();
    expect(lud.displayName, 'Ludmilla');
    expect(lud.coverUrl, isNotEmpty);
    expect(lud.memberCount, 512000);
    expect(lud.rank, 2);
    expect(lud.following, isNull);
    expect(lud.subscribed, isNull);
    expect(lud.feedPosts.first.text, contains('estúdio'));

    final lais = Cf185ArtistFeedFixtures.lais();
    expect(lais.displayName, 'Laís Costa');
    expect(lais.following, isFalse);
    expect(lais.subscribed, isFalse);
    expect(lais.memberCount, 215);
    expect(lais.rank, 4);
    expect(lais.feedPosts.first.text, contains('Dump de backstage'));

    final mayra = Cf185ArtistFeedFixtures.mayra();
    expect(mayra.subscribed, isTrue);
    expect(mayra.following, isTrue);
    expect(mayra.memberCount, 368000);
    expect(mayra.rank, 3);
    expect(mayra.feedPosts, hasLength(2));

    expect(
      Cf185ArtistFeedFixtures.resolve('mock-fc-lais', 'Laís Costa')?.rank,
      4,
    );
    expect(Cf185ArtistFeedFixtures.resolve('other', 'Nobody'), isNull);
  });

  test('CF-185: membros formatados como no print', () {
    expect(
      ArtistProfilePublicCover.formatMembers(512000),
      '512,0 mil membros',
    );
    expect(ArtistProfilePublicCover.formatMembers(215), '215 membros');
    expect(
      ArtistProfilePublicCover.formatMembers(368000),
      '368,0 mil membros',
    );
  });

  testWidgets('CF-185: cover mostra + Seguir quando não segue', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: ArtistProfilePublicCover(
            imageUrl: Cf185ArtistFeedFixtures.ludmilla().coverUrl,
            displayName: 'Ludmilla',
            membersLabel: '512,0 mil membros',
            rank: 2,
            following: false,
            subscribed: false,
            busy: false,
            onBack: () {},
            onMore: () {},
            onToggleFollow: () {},
            onMembership: () {},
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('+ Seguir'), findsOneWidget);
    expect(find.text('Seguindo'), findsNothing);
    expect(find.textContaining('Membership'), findsNothing);
    expect(find.text('Ludmilla'), findsOneWidget);
    expect(find.text('#2'), findsOneWidget);
    expect(find.text('512,0 mil membros'), findsOneWidget);
  });

  testWidgets('CF-185: cover Membership ♪ quando segue sem assinatura', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: ArtistProfilePublicCover(
            imageUrl: Cf185ArtistFeedFixtures.lais().coverUrl,
            displayName: 'Laís Costa',
            membersLabel: '215 membros',
            rank: 4,
            following: true,
            subscribed: false,
            busy: false,
            onBack: () {},
            onMore: () {},
            onToggleFollow: () {},
            onMembership: () {},
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Membership'), findsOneWidget);
    expect(find.text('+ Seguir'), findsNothing);
    expect(find.text('Seguindo'), findsNothing);
    expect(find.byIcon(Icons.check), findsNothing);
  });

  testWidgets('CF-185: cover Membership ✓ quando assinante', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: ArtistProfilePublicCover(
            imageUrl: Cf185ArtistFeedFixtures.mayra().coverUrl,
            displayName: 'Mayra',
            membersLabel: '368,0 mil membros',
            rank: 3,
            following: true,
            subscribed: true,
            busy: false,
            onBack: () {},
            onMore: () {},
            onToggleFollow: () {},
            onMembership: () {},
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Membership'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.text('+ Seguir'), findsNothing);
    expect(find.text('Seguindo'), findsNothing);
  });

  testWidgets('CF-185: capa existente não cai no fundo escuro vazio', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: ArtistProfilePublicCover(
            imageUrl: Cf185ArtistFeedFixtures.ludmilla().coverUrl,
            displayName: 'Ludmilla',
            membersLabel: '512,0 mil membros',
            following: false,
            subscribed: false,
            busy: false,
            onBack: () {},
            onMore: () {},
            onToggleFollow: () {},
            onMembership: () {},
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(Image), findsOneWidget);
  });
}
