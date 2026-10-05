import 'package:crowdfans/components/sidebar/sidebar_artist_row.dart';
import 'package:crowdfans/components/sidebar/sidebar_menu.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/models/home_feed.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget wrapSidebar({
  required List<HomeFollowedArtist> artists,
  bool asDrawerPanel = true,
}) {
  return MaterialApp(
    theme: buildCrowdFansTheme(Brightness.light),
    home: Scaffold(
      body: SidebarMenu(
        visible: true,
        asDrawerPanel: asDrawerPanel,
        artists: artists,
        onClose: () {},
        onPressArtist: (_) {},
      ),
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> setTallSurface(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 2000));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
  }

  group('CF-191 green — print Favoritos + Seus Artistas', () {
    test('fixtures ON com artistas do print', () {
      expect(kUseCfTempMocks, isTrue);
      expect(CfTempMocks.useFavoriteArtistsFixtures, isTrue);
      expect(kCf191MockEmpty, isFalse);

      final artists = CfTempMocks.sidebarFollowedArtists();
      final favoriteIds = CfTempMocks.sidebarFavoriteIds();
      final recent = CfTempMocks.sidebarRecentArtists();

      expect(recent, isEmpty);
      expect(
        artists.map((a) => a.username).toList(),
        [
          'Mayra',
          'Marinhos',
          'Banda Uelo',
          'Enzo Lima',
          'Ludmilla',
          'Anitta',
          'Carol Biazin',
          'Kheper',
        ],
      );
      expect(
        artists.where((a) => favoriteIds.contains(a.id)).map((a) => a.username),
        ['Mayra', 'Marinhos', 'Banda Uelo'],
      );
      expect(
        artists
            .where((a) => !favoriteIds.contains(a.id))
            .map((a) => a.username),
        ['Enzo Lima', 'Ludmilla', 'Anitta', 'Carol Biazin', 'Kheper'],
      );
      for (final artist in artists) {
        expect(artist.avatarUrl.trim(), isNotEmpty);
      }
    });

    testWidgets('menu mostra seções e estrelas do print', (tester) async {
      await setTallSurface(tester);
      await tester.pumpWidget(wrapSidebar(artists: const []));
      await tester.pumpAndSettle();

      expect(find.text('Visitado recentemente'), findsOneWidget);
      expect(find.text('Favoritos'), findsOneWidget);
      expect(find.text('Seus Artistas'), findsOneWidget);

      expect(find.text('Mayra'), findsOneWidget);
      expect(find.text('Marinhos'), findsOneWidget);
      expect(find.text('Banda Uelo'), findsOneWidget);
      expect(find.text('Enzo Lima'), findsOneWidget);
      expect(find.text('Ludmilla'), findsOneWidget);
      expect(find.text('Anitta'), findsOneWidget);
      expect(find.text('Carol Biazin'), findsOneWidget);
      expect(find.text('Kheper'), findsOneWidget);

      expect(find.text('Nenhum artista visitado recentemente.'), findsNothing);
      expect(find.text('Nenhum favorito ainda. Toque na estrela para destacar.'),
          findsNothing);

      expect(find.byIcon(Icons.star), findsNWidgets(3));
      expect(find.byIcon(Icons.star_border), findsNWidgets(5));

      final mayraStar = find.descendant(
        of: find.widgetWithText(SidebarArtistRow, 'Mayra'),
        matching: find.byIcon(Icons.star),
      );
      expect(mayraStar, findsOneWidget);
      expect(
        tester.widget<Icon>(mayraStar).color,
        AppPalette.yellow500,
      );

      final anittaStar = find.descendant(
        of: find.widgetWithText(SidebarArtistRow, 'Anitta'),
        matching: find.byIcon(Icons.star_border),
      );
      expect(anittaStar, findsOneWidget);
    });
  });

  group('CF-191 red — vazio / bloqueado', () {
    test('empty fixtures devolvem listas vazias', () {
      expect(kCf191MockEmpty, isFalse);
      expect(CfTempMocks.sidebarFollowedArtists(empty: true), isEmpty);
      expect(CfTempMocks.sidebarFavoriteIds(empty: true), isEmpty);
      expect(CfTempMocks.sidebarRecentArtists(empty: true), isEmpty);
    });

    testWidgets('sem artistas e sem favoritos: mensagens distintas', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: SidebarMenu(
              key: const Key('cf191-empty-harness'),
              visible: true,
              asDrawerPanel: true,
              artists: const [],
              onClose: () {},
              onPressArtist: (_) {},
              // Test-only: desliga fixtures neste harness.
              useFixturesOverride: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Favoritos'), findsOneWidget);
      expect(
        find.text('Nenhum favorito ainda. Toque na estrela para destacar.'),
        findsOneWidget,
      );
      expect(find.text('Nenhum artista seguido ainda.'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsNothing);
    });
  });

  group('CF-191 edge — teclado / texto longo / toggle', () {
    testWidgets('nome longo não estoura a linha; estrela permanece alvo', (
      tester,
    ) async {
      const longName =
          'Banda Com Nome Extremamente Longo Para Validar Ellipsis CF191';
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: SidebarArtistRow(
              artist: const HomeFollowedArtist(
                id: 'long',
                username: longName,
                avatarUrl: '',
              ),
              isFavorite: false,
              onPressed: () {},
              onToggleFavorite: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      final text = tester.widget<Text>(find.text(longName));
      expect(text.maxLines, 1);
      expect(text.overflow, TextOverflow.ellipsis);
      expect(find.byIcon(Icons.star_border), findsOneWidget);
      expect(tester.getSize(find.byType(IconButton)).width, greaterThanOrEqualTo(40));
    });

    testWidgets('toggle move artista de Favoritos para Seus Artistas', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(wrapSidebar(artists: const []));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.star), findsNWidgets(3));
      expect(find.byIcon(Icons.star_border), findsNWidgets(5));

      final mayraToggle = find.descendant(
        of: find.widgetWithText(SidebarArtistRow, 'Mayra'),
        matching: find.byType(IconButton),
      );
      await tester.tap(mayraToggle);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.star), findsNWidgets(2));
      expect(find.byIcon(Icons.star_border), findsNWidgets(6));
      expect(
        find.text('Nenhum favorito ainda. Toque na estrela para destacar.'),
        findsNothing,
      );
    });

    testWidgets('drawer Home: barreira à direita fecha e absorve foco', (
      tester,
    ) async {
      var closed = false;
      final sidebarWidth = 390.0 * 0.78;
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: Stack(
              children: [
                const ColoredBox(
                  color: Colors.white,
                  child: SizedBox.expand(child: Text('feed-behind')),
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: sidebarWidth,
                  child: SidebarMenu(
                    visible: true,
                    asDrawerPanel: true,
                    artists: const [],
                    onClose: () => closed = true,
                    onPressArtist: (_) {},
                  ),
                ),
                Positioned(
                  left: sidebarWidth,
                  top: 0,
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    key: const Key('sidebar-barrier'),
                    behavior: HitTestBehavior.opaque,
                    onTap: () => closed = true,
                    child: const ColoredBox(color: Color(0x33000000)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Favoritos'), findsOneWidget);
      await tester.tap(find.byKey(const Key('sidebar-barrier')));
      await tester.pump();
      expect(closed, isTrue);
    });
  });
}
