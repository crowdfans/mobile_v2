import 'package:crowdfans/components/fan_club/fan_club_compose_artist.dart';
import 'package:crowdfans/components/fan_club/fan_club_selector_dropdown.dart';
import 'package:crowdfans/components/fan_club/fan_club_selector_field.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final artists = cfTempMockFanClubSelectorArtists();

  test('CF-237 fixtures: ordem e avatares do print', () {
    expect(CfTempMocks.useFanClubSelectorFixtures, isTrue);
    expect(artists.map((a) => a.name).toList(), [
      'Mayra',
      'Marinhos',
      'Banda Uelo',
      'Enzo Lima',
      'Ludmilla',
      'Anitta',
    ]);
    expect(artists.every((a) => a.avatarUrl.startsWith('http')), isTrue);
  });

  test('CF-237 altura útil encolhe com teclado e mantém mínimo', () {
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

  testWidgets(
    'CF-237 seletor expandido: busca, lista rolável e seleção no resumo',
    (tester) async {
      FanClubComposeArtist? selected;
      var expanded = true;

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
                      onPressed: () =>
                          setState(() => expanded = !expanded),
                    ),
                    if (expanded) ...[
                      const SizedBox(height: 8),
                      FanClubSelectorDropdown(
                        artists: artists,
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
      expect(find.byKey(const Key('novo-post-club-search')), findsOneWidget);
      expect(find.byKey(const Key('novo-post-club-results')), findsOneWidget);
      for (final name in [
        'Mayra',
        'Marinhos',
        'Banda Uelo',
        'Enzo Lima',
        'Ludmilla',
        'Anitta',
      ]) {
        expect(find.text(name), findsOneWidget);
      }

      await tester.enterText(
        find.byKey(const Key('novo-post-club-search')),
        'Lud',
      );
      await tester.pumpAndSettle();
      expect(find.text('Ludmilla'), findsOneWidget);
      expect(find.text('Mayra'), findsNothing);
      expect(find.byKey(const Key('novo-post-club-search-clear')), findsOneWidget);

      await tester.tap(find.text('Ludmilla'));
      await tester.pumpAndSettle();

      expect(find.text('Ludmilla'), findsOneWidget);
      expect(find.text('Selecionar Fã Clube'), findsNothing);
      expect(find.byKey(const Key('novo-post-club-results')), findsNothing);
      expect(selected?.id, 'mock-fc-ludmilla');
    },
  );

  testWidgets('CF-237 com teclado: lista mantém altura útil rolável', (
    tester,
  ) async {
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
              artists: artists,
              selectedId: null,
              onSelect: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final list = tester.widget<ListView>(
      find.byKey(const Key('novo-post-club-results')),
    );
    expect(list.shrinkWrap, isTrue);

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

  testWidgets('CF-237 busca sem resultado: estado vazio distinto', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: FanClubSelectorDropdown(
            artists: artists,
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
}
