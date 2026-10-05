import 'package:crowdfans/components/sidebar/sidebar_menu.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/home_feed.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _artist = HomeFollowedArtist(
  id: 'a1',
  username: 'mayra',
  avatarUrl: '',
);

const _longArtist = HomeFollowedArtist(
  id: 'a2',
  username: 'artista_com_nome_extremamente_longo_para_edge_cf265',
  avatarUrl: '',
);

/// Espelho do uso em FanClubs: SidebarMenu no Stack (overlay full-screen).
class _OverlaySidebarHarness extends StatefulWidget {
  const _OverlaySidebarHarness({
    this.artists = const [_artist],
    this.initialVisible = true,
  });

  final List<HomeFollowedArtist> artists;
  final bool initialVisible;

  @override
  State<_OverlaySidebarHarness> createState() => _OverlaySidebarHarnessState();
}

class _OverlaySidebarHarnessState extends State<_OverlaySidebarHarness> {
  late var _visible = widget.initialVisible;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_visible,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _visible) {
          setState(() => _visible = false);
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            const ColoredBox(
              color: Colors.white,
              child: SizedBox.expand(
                child: Center(child: Text('feed-behind')),
              ),
            ),
            SidebarMenu(
              visible: _visible,
              artists: widget.artists,
              onClose: () => setState(() => _visible = false),
              onPressArtist: (_) {},
            ),
          ],
        ),
      ),
    );
  }
}

/// Espelho do uso na Home: painel + barreira posicionados (asDrawerPanel).
class _DrawerSidebarHarness extends StatefulWidget {
  const _DrawerSidebarHarness({this.artists = const [_artist]});

  final List<HomeFollowedArtist> artists;

  @override
  State<_DrawerSidebarHarness> createState() => _DrawerSidebarHarnessState();
}

class _DrawerSidebarHarnessState extends State<_DrawerSidebarHarness> {
  var _visible = true;
  String? _pressedId;

  void handleClose() => setState(() => _visible = false);

  void handlePressArtist(HomeFollowedArtist artist) {
    // Mesmo contrato da Home: fecha antes de “navegar”.
    handleClose();
    setState(() => _pressedId = artist.id);
  }

  @override
  Widget build(BuildContext context) {
    final sidebarWidth = MediaQuery.sizeOf(context).width * 0.78;
    return PopScope(
      canPop: !_visible,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _visible) {
          handleClose();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            ColoredBox(
              color: Colors.white,
              child: SizedBox.expand(
                child: Center(
                  child: Text(_pressedId ?? 'feed-behind'),
                ),
              ),
            ),
            if (_visible) ...[
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: sidebarWidth,
                child: SidebarMenu(
                  visible: true,
                  asDrawerPanel: true,
                  artists: widget.artists,
                  onClose: handleClose,
                  onPressArtist: handlePressArtist,
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
                  onTap: handleClose,
                  child: const ColoredBox(color: Color(0x33000000)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Future<void> _pumpApp(WidgetTester tester, Widget home) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: buildCrowdFansTheme(Brightness.light),
      home: home,
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('CF-265 Sidebar Favoritos — green', () {
    testWidgets('tap na barreira (overlay) fecha o menu de favoritos', (
      tester,
    ) async {
      await _pumpApp(tester, const _OverlaySidebarHarness());

      expect(find.text('Favoritos'), findsOneWidget);

      final size = tester.getSize(find.byType(Scaffold));
      await tester.tapAt(Offset(size.width * 0.92, size.height * 0.4));
      await tester.pumpAndSettle();

      expect(find.text('Favoritos'), findsNothing);
      expect(find.text('feed-behind'), findsOneWidget);
    });

    testWidgets('tap na barreira (drawer Home) fecha o menu', (tester) async {
      await _pumpApp(tester, const _DrawerSidebarHarness());

      expect(find.text('Favoritos'), findsOneWidget);

      await tester.tap(find.byKey(const Key('sidebar-barrier')));
      await tester.pumpAndSettle();

      expect(find.text('Favoritos'), findsNothing);
    });

    testWidgets('botão fechar (X) dispensa o painel', (tester) async {
      await _pumpApp(tester, const _OverlaySidebarHarness());

      expect(find.text('Favoritos'), findsOneWidget);

      await tester.tap(find.byKey(const Key('sidebar-close')));
      await tester.pumpAndSettle();

      expect(find.text('Favoritos'), findsNothing);
    });

    testWidgets('system back fecha o menu (PopScope) sem pop da rota', (
      tester,
    ) async {
      await _pumpApp(tester, const _OverlaySidebarHarness());
      expect(find.text('Favoritos'), findsOneWidget);

      // PopScope.canPop=false → fecha o menu; a rota Home permanece.
      final handled = await tester.binding.handlePopRoute();
      expect(handled, isTrue);
      await tester.pumpAndSettle();

      expect(find.text('Favoritos'), findsNothing);
      expect(find.text('feed-behind'), findsOneWidget);
    });

    testWidgets('toque no artista fecha o drawer (Home) antes de navegar', (
      tester,
    ) async {
      await _pumpApp(tester, const _DrawerSidebarHarness());
      expect(find.text('Favoritos'), findsOneWidget);

      await tester.tap(find.text('mayra'));
      await tester.pumpAndSettle();

      expect(find.text('Favoritos'), findsNothing);
      expect(find.text('a1'), findsOneWidget);
    });
  });

  group('CF-265 Sidebar Favoritos — red', () {
    testWidgets('menu invisível não mostra Favoritos nem barreira', (
      tester,
    ) async {
      await _pumpApp(
        tester,
        const _OverlaySidebarHarness(initialVisible: false),
      );

      expect(find.text('Favoritos'), findsNothing);
      expect(find.byKey(const Key('sidebar-barrier')), findsNothing);
      expect(find.byKey(const Key('sidebar-close')), findsNothing);
      expect(find.text('feed-behind'), findsOneWidget);
    });

    testWidgets('tap dentro do painel não fecha o menu', (tester) async {
      await _pumpApp(tester, const _OverlaySidebarHarness());
      expect(find.text('Favoritos'), findsOneWidget);

      await tester.tap(find.text('Favoritos'));
      await tester.pumpAndSettle();

      expect(find.text('Favoritos'), findsOneWidget);
    });

    testWidgets('lista vazia ainda exige dismiss explícito (não auto-fecha)', (
      tester,
    ) async {
      await _pumpApp(
        tester,
        const _OverlaySidebarHarness(artists: []),
      );

      expect(find.text('Favoritos'), findsOneWidget);
      expect(
        find.text('Nenhum favorito ainda. Toque na estrela para destacar.'),
        findsOneWidget,
      );
      expect(find.text('Nenhum artista seguido ainda.'), findsOneWidget);

      // Sem dismiss — permanece aberto (não “some” por vazio).
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Favoritos'), findsOneWidget);

      await tester.tap(find.byKey(const Key('sidebar-close')));
      await tester.pumpAndSettle();
      expect(find.text('Favoritos'), findsNothing);
    });
  });

  group('CF-265 Sidebar Favoritos — edge', () {
    testWidgets('nome longo no painel não impede fechar pelo X', (tester) async {
      await _pumpApp(
        tester,
        const _OverlaySidebarHarness(artists: [_longArtist]),
      );

      expect(
        find.textContaining('artista_com_nome_extremamente_longo'),
        findsWidgets,
      );

      await tester.tap(find.byKey(const Key('sidebar-close')));
      await tester.pumpAndSettle();
      expect(find.text('Favoritos'), findsNothing);
    });

    testWidgets('abrir/fechar rápido (toggle) termina fechado', (tester) async {
      await _pumpApp(tester, const _OverlaySidebarHarness());
      final size = tester.getSize(find.byType(Scaffold));

      await tester.tapAt(Offset(size.width * 0.92, size.height * 0.4));
      await tester.pump(); // mid-animation
      await tester.pumpAndSettle();
      expect(find.text('Favoritos'), findsNothing);
    });

    testWidgets('drawer Home: back com lista vazia fecha o menu', (
      tester,
    ) async {
      await _pumpApp(tester, const _DrawerSidebarHarness(artists: []));
      expect(find.text('Favoritos'), findsOneWidget);

      final handled = await tester.binding.handlePopRoute();
      expect(handled, isTrue);
      await tester.pumpAndSettle();
      expect(find.text('Favoritos'), findsNothing);
      expect(find.text('feed-behind'), findsOneWidget);
    });
  });
}
