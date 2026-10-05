import 'package:crowdfans/components/profile/artist_profile_cover_cta.dart';
import 'package:crowdfans/components/profile/artist_profile_public_cover.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CF-185 demock — green', () {
    test('flag off; fixtures ainda resolvem samples de print', () {
      expect(kUseCfTempMocks, isTrue);
      expect(kUseCf185ArtistFeedMocks, isFalse);

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
    });

    test('CTA Seguir / Membership♪ / ✓ a partir de follow+sub reais', () {
      expect(
        artistProfileCoverCtaKind(following: false, subscribed: false),
        ArtistProfileCoverCtaKind.follow,
      );
      expect(
        artistProfileCoverCtaKind(following: true, subscribed: false),
        ArtistProfileCoverCtaKind.membershipSubscribe,
      );
      expect(
        artistProfileCoverCtaKind(following: true, subscribed: true),
        ArtistProfileCoverCtaKind.membershipActive,
      );
    });

    test('membros formatados como no print', () {
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

    testWidgets('cover mostra + Seguir quando não segue', (tester) async {
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

    testWidgets('cover Membership ♪ quando segue sem assinatura', (
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

    testWidgets('cover Membership ✓ quando assinante', (tester) async {
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
  });

  group('CF-185 demock — red', () {
    test('artista desconhecido não resolve fixture', () {
      expect(Cf185ArtistFeedFixtures.resolve('other', 'Nobody'), isNull);
      expect(Cf185ArtistFeedFixtures.resolve('', null), isNull);
    });

    testWidgets('capa vazia → fundo escuro, sem Image.network', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: ArtistProfilePublicCover(
              imageUrl: '',
              displayName: 'Sem capa',
              membersLabel: '0 membros',
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
      expect(find.byType(Image), findsNothing);
      expect(find.text('+ Seguir'), findsOneWidget);
      expect(find.text('Seguindo'), findsNothing);
    });

    testWidgets('busy bloqueia CTA com Aguarde...', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: ArtistProfilePublicCover(
              imageUrl: '',
              displayName: 'Busy',
              membersLabel: '1 membro',
              following: false,
              subscribed: false,
              busy: true,
              onBack: () {},
              onMore: () {},
              onToggleFollow: () {},
              onMembership: () {},
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Aguarde...'), findsOneWidget);
      expect(find.text('+ Seguir'), findsNothing);
    });
  });

  group('CF-185 demock — edge', () {
    test('assinante sem follow ainda mostra Membership ✓', () {
      expect(
        artistProfileCoverCtaKind(following: false, subscribed: true),
        ArtistProfileCoverCtaKind.membershipActive,
      );
    });

    test('formatMembers null/zero e milhão', () {
      expect(
        ArtistProfilePublicCover.formatMembers(null),
        'Sem membros ainda',
      );
      expect(ArtistProfilePublicCover.formatMembers(0), '0 membros');
      expect(
        ArtistProfilePublicCover.formatMembers(1_000_000),
        '1,0 mi membros',
      );
    });

    testWidgets('capa existente não cai no fundo escuro vazio', (tester) async {
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

    testWidgets('nome longo no cover não quebra layout', (tester) async {
      const longName =
          'Artista Com Nome Extremamente Longo Para Edge Case De Layout CF-185';
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: ArtistProfilePublicCover(
              imageUrl: '',
              displayName: longName,
              membersLabel: '999.999 membros',
              rank: 500,
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
      expect(find.textContaining('Artista Com Nome'), findsOneWidget);
      expect(find.text('Membership'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
