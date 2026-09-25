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

/// Espelho do uso em FanClubs: SidebarMenu no Stack (overlay full-screen).
class _OverlaySidebarHarness extends StatefulWidget {
  const _OverlaySidebarHarness();

  @override
  State<_OverlaySidebarHarness> createState() => _OverlaySidebarHarnessState();
}

class _OverlaySidebarHarnessState extends State<_OverlaySidebarHarness> {
  var _visible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            artists: const [_artist],
            onClose: () => setState(() => _visible = false),
            onPressArtist: (_) {},
          ),
        ],
      ),
    );
  }
}

/// Espelho do uso na Home: painel + barreira posicionados (asDrawerPanel).
class _DrawerSidebarHarness extends StatefulWidget {
  const _DrawerSidebarHarness();

  @override
  State<_DrawerSidebarHarness> createState() => _DrawerSidebarHarnessState();
}

class _DrawerSidebarHarnessState extends State<_DrawerSidebarHarness> {
  var _visible = true;

  void handleClose() => setState(() => _visible = false);

  @override
  Widget build(BuildContext context) {
    final sidebarWidth = MediaQuery.sizeOf(context).width * 0.78;
    return Scaffold(
      body: Stack(
        children: [
          const ColoredBox(color: Colors.white, child: SizedBox.expand()),
          if (_visible) ...[
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: sidebarWidth,
              child: SidebarMenu(
                visible: true,
                asDrawerPanel: true,
                artists: const [_artist],
                onClose: handleClose,
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
                onTap: handleClose,
                child: const ColoredBox(color: Color(0x33000000)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

void main() {
  group('CF-265 Sidebar Favoritos fecha', () {
    testWidgets('tap na barreira (overlay) fecha o menu de favoritos', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: const _OverlaySidebarHarness(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Favoritos'), findsOneWidget);

      // Tap à direita do painel (~78%): barreira full-screen.
      final size = tester.getSize(find.byType(Scaffold));
      await tester.tapAt(Offset(size.width * 0.92, size.height * 0.4));
      await tester.pumpAndSettle();

      expect(find.text('Favoritos'), findsNothing);
    });

    testWidgets('tap na barreira (drawer Home) fecha o menu', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: const _DrawerSidebarHarness(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Favoritos'), findsOneWidget);

      await tester.tap(find.byKey(const Key('sidebar-barrier')));
      await tester.pumpAndSettle();

      expect(find.text('Favoritos'), findsNothing);
    });

    testWidgets('botão fechar (X) dispensa o painel', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: const _OverlaySidebarHarness(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Favoritos'), findsOneWidget);

      await tester.tap(find.byKey(const Key('sidebar-close')));
      await tester.pumpAndSettle();

      expect(find.text('Favoritos'), findsNothing);
    });
  });
}
