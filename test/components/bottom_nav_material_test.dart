import 'package:crowdfans/components/navigation/bottom_nav_bar.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/profile.dart';
import 'package:crowdfans/state/auth_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

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

GoRoute _leaf(String path) => GoRoute(
      path: path,
      builder: (context, state) => const SizedBox.expand(),
    );

/// Espelho do MainShell pós-CF-133: nav fora do Scaffold (acima do sheet).
Widget _shellWithoutScaffoldMaterial(StatefulNavigationShell navigationShell) {
  return Stack(
    children: [
      Scaffold(body: navigationShell),
      Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: BottomNavBar(
          navigationShell: navigationShell,
          onPressPlus: () {},
        ),
      ),
    ],
  );
}

void main() {
  testWidgets(
    'BottomNavBar fora do Scaffold não lança No Material widget found',
    (tester) async {
      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              return _shellWithoutScaffoldMaterial(navigationShell);
            },
            branches: [
              StatefulShellBranch(routes: [_leaf('/home')]),
              StatefulShellBranch(routes: [_leaf('/clubs')]),
              StatefulShellBranch(routes: [_leaf('/search')]),
              StatefulShellBranch(routes: [_leaf('/profile')]),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authSessionProvider.overrideWith(_FakeAuthSessionNotifier.new),
          ],
          child: MaterialApp.router(
            theme: buildCrowdFansTheme(Brightness.light),
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('nav-home')), findsOneWidget);
      expect(find.byKey(const Key('nav-create')), findsOneWidget);
      expect(find.byKey(const Key('nav-profile')), findsOneWidget);
      expect(find.textContaining('No Material widget found'), findsNothing);
    },
  );
}
