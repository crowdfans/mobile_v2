import 'package:crowdfans/components/home/create_menu_item_button.dart';
import 'package:crowdfans/components/home/create_menu_sheet.dart';
import 'package:crowdfans/components/ui/bottom_sheet_shell.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/profile.dart';
import 'package:crowdfans/state/auth_session.dart';
import 'package:crowdfans/state/create_menu_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeFanAuth extends AuthSessionNotifier {
  @override
  AuthSession build() {
    return const AuthSession(
      isLoading: false,
      isBackendValidated: true,
      profile: Profile(
        userUid: 'fan-1',
        displayName: 'Fan',
        name: 'Fan',
        description: '',
        photoUrl: '',
        isArtist: false,
      ),
    );
  }
}

/// Espelho do MainShell: sheet + nav; origem permanece ao fechar.
class _Cf188ShellHarness extends ConsumerWidget {
  const _Cf188ShellHarness();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final open = ref.watch(createMenuProvider);
    return Stack(
      children: [
        const Scaffold(
          body: Center(child: Text('tela-origem', key: Key('origin-screen'))),
        ),
        CreateMenuSheet(
          visible: open,
          onClose: () => ref.read(createMenuProvider.notifier).closeMenu(),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Material(
            color: Colors.white,
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 68,
                child: Center(
                  child: IconButton(
                    key: const Key('nav-create'),
                    onPressed: () {
                      ref.read(createMenuProvider.notifier).toggleMenu();
                    },
                    icon: const Icon(Icons.add),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

void main() {
  test('CF-188: respiro extra além da área segura', () {
    expect(createMenuSheetExtraBottom(34), 16);
    expect(createMenuSheetExtraBottom(0), 24);
    expect(createMenuSheetExtraBottom(8), 24);
  });

  testWidgets(
    'CF-188: Fan Letter / Post Fã Clube cobrem nav; fechar mantém origem',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authSessionProvider.overrideWith(_FakeFanAuth.new),
          ],
          child: MaterialApp(
            theme: buildCrowdFansTheme(Brightness.light),
            home: const _Cf188ShellHarness(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('origin-screen')), findsOneWidget);
      expect(find.text('Fan Letter'), findsNothing);

      await tester.tap(find.byKey(const Key('nav-create')));
      await tester.pumpAndSettle();

      expect(find.text('Fan Letter'), findsOneWidget);
      expect(find.text('Post Fã Clube'), findsOneWidget);

      final shell = tester.widget<BottomSheetShell>(
        find.byType(BottomSheetShell),
      );
      expect(shell.coverNavigation, isTrue);
      expect(shell.bottomOffset, greaterThan(0));

      final fanLetter = tester.getSize(
        find.byKey(const Key('create-menu-fan-letters')),
      );
      final fanClub = tester.getSize(
        find.byKey(const Key('create-menu-fan-club-post')),
      );
      expect(fanLetter.height, greaterThanOrEqualTo(64));
      expect(fanClub.height, greaterThanOrEqualTo(64));

      // Fecha pelo overlay — origem permanece (sem pop de rota).
      await tester.tapAt(const Offset(20, 20));
      await tester.pumpAndSettle();

      expect(find.text('Fan Letter'), findsNothing);
      expect(find.byKey(const Key('origin-screen')), findsOneWidget);
    },
  );

  testWidgets('CF-188: item do seletor tem altura de toque 64', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            child: CreateMenuItemButton(
              key: const Key('item'),
              asset: 'assets/icons/Communication/mail-01.svg',
              label: 'Fan Letter',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final size = tester.getSize(find.byKey(const Key('item')));
    expect(size.height, greaterThanOrEqualTo(64));

    await tester.tap(find.text('Fan Letter'));
    expect(tapped, isTrue);
  });
}
