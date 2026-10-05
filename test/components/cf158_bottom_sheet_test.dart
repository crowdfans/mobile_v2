import 'package:crowdfans/components/post/post_options_sheet.dart';
import 'package:crowdfans/components/post/post_share_sheet.dart';
import 'package:crowdfans/components/ui/bottom_sheet_shell.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Espelho do MainShell: conteúdo + sheet + nav por cima no Stack.
class _Cf158ShellHarness extends StatefulWidget {
  const _Cf158ShellHarness({required this.sheetVisible});

  final bool sheetVisible;

  @override
  State<_Cf158ShellHarness> createState() => _Cf158ShellHarnessState();
}

class _Cf158ShellHarnessState extends State<_Cf158ShellHarness> {
  late bool _visible = widget.sheetVisible;

  @override
  void didUpdateWidget(covariant _Cf158ShellHarness oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sheetVisible != widget.sheetVisible) {
      _visible = widget.sheetVisible;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Scaffold(
          body: Center(child: Text('feed', key: Key('cf158-feed'))),
        ),
        BottomSheetShell(
          visible: _visible,
          onClose: () => setState(() => _visible = false),
          child: const Text('cf158-sheet-body', key: Key('cf158-sheet-body')),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Material(
            key: const Key('cf158-nav'),
            color: Colors.white,
            child: SizedBox(
              height: 68,
              child: Center(
                child: TextButton(
                  key: const Key('cf158-nav-home'),
                  onPressed: () {},
                  child: const Text('NavHome'),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

bool _semanticsScopesRouteSafely(Semantics widget) {
  if (widget.properties.scopesRoute != true) {
    return true;
  }
  // Flutter assert: scopesRoute ⇒ explicitChildNodes (object.dart ~4948).
  return widget.explicitChildNodes;
}

void main() {
  // --- GREEN: sheet acima da nav + slide-only ---
  testWidgets(
    'CF-158 green: coverNavigation coloca sheet no Overlay acima da nav',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: const _Cf158ShellHarness(sheetVisible: true),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 320));

      final shell = tester.widget<BottomSheetShell>(
        find.byType(BottomSheetShell),
      );
      expect(shell.coverNavigation, isTrue);

      expect(find.byKey(const Key('cf158-sheet-body')), findsOneWidget);
      expect(find.byKey(const Key('cf158-nav')), findsOneWidget);

      // Conteúdo do sheet vive no Overlay raiz (acima do Stack da nav).
      expect(
        find.descendant(
          of: find.byType(Overlay),
          matching: find.byKey(const Key('cf158-sheet-body')),
        ),
        findsOneWidget,
      );

      // Overlay do sheet fica acima da nav do Stack (z-order CF-158).
      final sheetDy = tester
          .getTopLeft(find.byKey(const Key('cf158-sheet-body')))
          .dy;
      final navDy = tester.getTopLeft(find.byKey(const Key('cf158-nav'))).dy;
      expect(sheetDy, lessThan(navDy + 68));
    },
  );

  testWidgets(
    'CF-158 green: abertura só com SlideTransition (sem fade de opacidade)',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: const _Cf158ShellHarness(sheetVisible: true),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));

      // Só o subtree do OverlayEntry do sheet (ignora Fade da MaterialPageRoute).
      final sheetInOverlay = find.descendant(
        of: find.byType(Overlay),
        matching: find.byKey(const Key('cf158-sheet-body')),
      );
      expect(sheetInOverlay, findsOneWidget);

      expect(
        find.ancestor(
          of: sheetInOverlay,
          matching: find.byType(SlideTransition),
        ),
        findsWidgets,
      );
      expect(
        find.ancestor(
          of: sheetInOverlay,
          matching: find.byType(FadeTransition),
        ),
        findsNothing,
      );
      expect(
        find.ancestor(
          of: sheetInOverlay,
          matching: find.byType(AnimatedOpacity),
        ),
        findsNothing,
      );

      final panelOpacities = find.ancestor(
        of: sheetInOverlay,
        matching: find.byWidgetPredicate(
          (w) => w is Opacity && w.opacity < 1.0,
        ),
      );
      expect(panelOpacities, findsNothing);
    },
  );

  // --- RED: não crashar ao abrir/fechar sheets com Semantics de rota ---
  testWidgets(
    'CF-158 red: PostShareSheet abre/fecha sem assert scopesRoute',
    (tester) async {
      var visible = true;
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Stack(
                  children: [
                    const SizedBox.expand(),
                    PostShareSheet(
                      visible: visible,
                      post: cfTempMockCf236SharePost(),
                      onClose: () => setState(() => visible = false),
                    ),
                    const Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: SizedBox(height: 68, child: Text('nav')),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 320));
      expect(find.byKey(const Key('post-share-sheet')), findsOneWidget);

      final semantics = tester.widgetList<Semantics>(find.byType(Semantics));
      for (final node in semantics) {
        expect(
          _semanticsScopesRouteSafely(node),
          isTrue,
          reason:
              'scopesRoute exige explicitChildNodes: true (crash Flutter #4948)',
        );
      }

      await tester.tapAt(const Offset(12, 12));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('post-share-sheet')), findsNothing);
    },
  );

  testWidgets(
    'CF-158 red: PostOptionsSheet abre/fecha sem assert scopesRoute',
    (tester) async {
      var visible = true;
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Stack(
                  children: [
                    const SizedBox.expand(),
                    PostOptionsSheet(
                      visible: visible,
                      post: cfTempMockCf236SharePost(),
                      onClose: () => setState(() => visible = false),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 320));
      expect(find.byKey(const Key('post-options-sheet')), findsOneWidget);

      final semantics = tester.widgetList<Semantics>(find.byType(Semantics));
      for (final node in semantics) {
        expect(_semanticsScopesRouteSafely(node), isTrue);
      }

      await tester.tapAt(const Offset(12, 12));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('post-options-sheet')), findsNothing);
    },
  );

  testWidgets(
    'CF-158 red: BottomSheetShell aplica Semantics de rota com explicitChildNodes',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: BottomSheetShell(
              visible: true,
              onClose: () {},
              child: const Text('shell-child', key: Key('shell-child')),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 320));

      final child = find.byKey(const Key('shell-child'));
      expect(child, findsOneWidget);

      // Ancestrais do conteúdo do sheet (não a MaterialPageRoute do home).
      final routeAncestors = tester
          .widgetList<Semantics>(
            find.ancestor(of: child, matching: find.byType(Semantics)),
          )
          .where((s) => s.properties.scopesRoute == true)
          .toList();
      expect(
        routeAncestors,
        isNotEmpty,
        reason: 'BottomSheetShell deve anunciar rota (scopesRoute)',
      );
      for (final node in routeAncestors) {
        expect(
          node.explicitChildNodes,
          isTrue,
          reason: 'scopesRoute sem explicitChildNodes crasha (gus CF-158)',
        );
      }
    },
  );

  // --- EDGE: área segura / teclado ---
  testWidgets(
    'CF-158 edge: padding inferior respeita safe area (e teclado via viewInsets)',
    (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            padding: EdgeInsets.only(bottom: 34),
            viewInsets: EdgeInsets.only(bottom: 120),
          ),
          child: MaterialApp(
            theme: buildCrowdFansTheme(Brightness.light),
            home: Scaffold(
              body: BottomSheetShell(
                visible: true,
                onClose: () {},
                child: const Text('edge-sheet', key: Key('edge-sheet')),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 320));

      expect(find.byKey(const Key('edge-sheet')), findsOneWidget);

      // Painel ancorado no rodapé; padding do shell ≥ safe bottom (34).
      final sheetTop = tester.getTopLeft(find.byKey(const Key('edge-sheet'))).dy;
      final screenH = tester.getSize(find.byType(MaterialApp)).height;
      expect(sheetTop, lessThan(screenH));

      final materials = tester.widgetList<Padding>(find.byType(Padding));
      final panelPads = materials.where((p) {
        final pad = p.padding;
        return pad is EdgeInsets &&
            pad.left == 16 &&
            pad.right == 16 &&
            pad.top == 8 &&
            pad.bottom >= 34;
      });
      expect(panelPads, isNotEmpty);
    },
  );
}
