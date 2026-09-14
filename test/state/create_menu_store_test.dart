import 'package:crowdfans/components/home/create_menu_sheet.dart';
import 'package:crowdfans/components/ui/bottom_sheet_shell.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/profile.dart';
import 'package:crowdfans/state/auth_session.dart';
import 'package:crowdfans/state/create_menu_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthSessionNotifier extends AuthSessionNotifier {
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

/// Espelho do MainShell: sheet + nav por cima com toggle no (+).
class _CreateMenuShellHarness extends ConsumerWidget {
  const _CreateMenuShellHarness();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final open = ref.watch(createMenuProvider);
    return Stack(
      children: [
        const Scaffold(body: SizedBox.expand()),
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
  test('toggleMenu abre e fecha o estado do menu +', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(createMenuProvider.notifier);
    expect(container.read(createMenuProvider), isFalse);

    notifier.toggleMenu();
    expect(container.read(createMenuProvider), isTrue);

    notifier.toggleMenu();
    expect(container.read(createMenuProvider), isFalse);
  });

  testWidgets('tap no overlay fecha o BottomSheetShell', (tester) async {
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
                  BottomSheetShell(
                    visible: visible,
                    onClose: () => setState(() => visible = false),
                    child: const Text('sheet-content'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('sheet-content'), findsOneWidget);

    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();

    expect(find.text('sheet-content'), findsNothing);
  });

  testWidgets('botão + abre e fecha o menu Criar', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(_FakeAuthSessionNotifier.new),
        ],
        child: MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: const _CreateMenuShellHarness(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Fan Letter'), findsNothing);

    await tester.tap(find.byKey(const Key('nav-create')));
    await tester.pumpAndSettle();
    expect(find.text('Fan Letter'), findsOneWidget);

    await tester.tap(find.byKey(const Key('nav-create')));
    await tester.pumpAndSettle();
    expect(find.text('Fan Letter'), findsNothing);
  });
}
