import 'package:crowdfans/components/fan_club/fan_club_compose_artist.dart';
import 'package:crowdfans/components/fan_club/fan_club_compose_candidates.dart';
import 'package:crowdfans/components/fan_club/fan_club_selector_dropdown.dart';
import 'package:crowdfans/components/fan_club/fan_club_selector_field.dart';
import 'package:crowdfans/components/profile/profile_state.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/services/follow_service.dart';
import 'package:crowdfans/services/subscription_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final printArtists = cfTempMockFanClubSelectorArtists();

  group('CF-237 demock — green', () {
    test('fixtures off; helper print ainda monta ordem Mayra…Anitta', () {
      expect(CfTempMocks.useFanClubSelectorFixtures, isFalse);
      expect(printArtists.map((a) => a.name).toList(), [
        'Mayra',
        'Marinhos',
        'Banda Uelo',
        'Enzo Lima',
        'Ludmilla',
        'Anitta',
      ]);
      expect(printArtists.every((a) => a.avatarUrl.startsWith('http')), isTrue);
    });

    test('merge follows/subs preenche seletor (não vazio)', () {
      final candidates = mergeFanClubComposeCandidates(
        subscriptions: const [
          Subscription(
            id: 1,
            userUid: 'fan',
            artistUid: 'art-sub',
            artistName: 'Artista Assinado',
            isActive: true,
            startDate: '2026-01-01',
          ),
        ],
        follows: const [
          ArtistFollow(
            artistUid: 'art-follow',
            artistName: 'Artista Seguido',
            avatarUrl: 'https://example.com/a.png',
            isFollowing: true,
          ),
        ],
      );
      expect(candidates.map((c) => c.id).toSet(), {'art-sub', 'art-follow'});
      expect(
        candidates.firstWhere((c) => c.id == 'art-follow').avatarUrl,
        'https://example.com/a.png',
      );
    });

    testWidgets('seletor expandido: busca, lista e seleção no resumo', (
      tester,
    ) async {
      FanClubComposeArtist? selected;
      var expanded = true;
      final apiArtists = mergeFanClubComposeCandidates(
        subscriptions: const [],
        follows: [
          for (final a in printArtists)
            ArtistFollow(
              artistUid: a.id,
              artistName: a.name,
              avatarUrl: a.avatarUrl,
              isFollowing: true,
            ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            resizeToAvoidBottomInset: false,
            body: StatefulBuilder(
              builder: (context, setState) {
                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    FanClubSelectorField(
                      selected: selected,
                      expanded: expanded,
                      onPressed: () => setState(() => expanded = !expanded),
                    ),
                    if (expanded) ...[
                      const SizedBox(height: 8),
                      FanClubSelectorDropdown(
                        artists: apiArtists,
                        selectedId: selected?.id,
                        onSelect: (artist) {
                          setState(() {
                            selected = artist;
                            expanded = false;
                          });
                        },
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Selecionar Fã Clube'), findsOneWidget);
      expect(find.text('Procurar Fã Clube'), findsOneWidget);
      expect(find.text('Ludmilla'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('novo-post-club-search')),
        'Lud',
      );
      await tester.pumpAndSettle();
      expect(find.text('Ludmilla'), findsOneWidget);
      expect(find.text('Mayra'), findsNothing);

      await tester.tap(find.text('Ludmilla'));
      await tester.pumpAndSettle();
      expect(selected?.id, 'mock-fc-ludmilla');
      expect(find.text('Selecionar Fã Clube'), findsNothing);
    });
  });

  group('CF-237 demock — red', () {
    test('merge vazio quando sem follows/subs ativos', () {
      final empty = mergeFanClubComposeCandidates(
        subscriptions: const [
          Subscription(
            id: 9,
            userUid: 'fan',
            artistUid: 'paused',
            artistName: 'Pausado',
            isActive: false,
            startDate: '2026-01-01',
          ),
        ],
        follows: const [],
      );
      expect(empty, isEmpty);
    });

    testWidgets('compose vazio: “Siga um artista…”', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: const Scaffold(
            body: ProfileState(
              title: 'Nenhum clube',
              message: 'Siga um artista para publicar no fã clube.',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Nenhum clube'), findsOneWidget);
      expect(
        find.text('Siga um artista para publicar no fã clube.'),
        findsOneWidget,
      );
    });

    testWidgets('busca sem resultado: estado vazio distinto', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: FanClubSelectorDropdown(
              artists: printArtists,
              selectedId: null,
              onSelect: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('novo-post-club-search')),
        'zzzz',
      );
      await tester.pumpAndSettle();
      expect(find.text('Nenhum fã clube encontrado.'), findsOneWidget);
    });
  });

  group('CF-237 demock — edge', () {
    test('sub ativa ganha sobre follow no mesmo artista (sem avatar)', () {
      final candidates = mergeFanClubComposeCandidates(
        subscriptions: const [
          Subscription(
            id: 2,
            userUid: 'fan',
            artistUid: 'same',
            artistName: 'Nome Assinatura',
            isActive: true,
            startDate: '2026-01-01',
          ),
        ],
        follows: const [
          ArtistFollow(
            artistUid: 'same',
            artistName: 'Nome Follow',
            avatarUrl: 'https://example.com/f.png',
            isFollowing: true,
          ),
        ],
      );
      expect(candidates, hasLength(1));
      expect(candidates.single.name, 'Nome Assinatura');
      expect(candidates.single.avatarUrl, isEmpty);
    });

    test('uid em branco é ignorado', () {
      final candidates = mergeFanClubComposeCandidates(
        subscriptions: const [
          Subscription(
            id: 3,
            userUid: 'fan',
            artistUid: '  ',
            artistName: 'Ignorado',
            isActive: true,
            startDate: '2026-01-01',
          ),
        ],
        follows: const [
          ArtistFollow(
            artistUid: '',
            artistName: 'Também',
            avatarUrl: '',
            isFollowing: true,
          ),
        ],
      );
      expect(candidates, isEmpty);
    });

    test('altura útil encolhe com teclado e mantém mínimo', () {
      final open = fanClubSelectorListMaxHeight(
        screenHeight: 844,
        keyboardInset: 0,
      );
      final withKeyboard = fanClubSelectorListMaxHeight(
        screenHeight: 844,
        keyboardInset: 300,
      );
      expect(open, greaterThan(withKeyboard));
      expect(withKeyboard, greaterThanOrEqualTo(120));
      expect(open, lessThanOrEqualTo(320));
    });

    testWidgets('com teclado: lista mantém altura útil rolável', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(390, 844),
            viewInsets: EdgeInsets.only(bottom: 300),
          ),
          child: MaterialApp(
            theme: buildCrowdFansTheme(Brightness.light),
            home: Scaffold(
              resizeToAvoidBottomInset: false,
              body: FanClubSelectorDropdown(
                artists: printArtists,
                selectedId: null,
                onSelect: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final constrained = tester.widget<ConstrainedBox>(
        find
            .ancestor(
              of: find.byKey(const Key('novo-post-club-results')),
              matching: find.byType(ConstrainedBox),
            )
            .first,
      );
      expect(constrained.constraints.maxHeight, greaterThanOrEqualTo(120));
      expect(constrained.constraints.maxHeight, lessThanOrEqualTo(320));
      expect(find.text('Mayra'), findsOneWidget);
    });
  });
}
