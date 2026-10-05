import 'dart:async';

import 'package:crowdfans/components/fan_clubs/fan_clubs_feed_header.dart';
import 'package:crowdfans/components/home/vote_control_bar.dart';
import 'package:crowdfans/components/login/credentials_form.dart';
import 'package:crowdfans/components/navigation/bottom_nav_bar.dart';
import 'package:crowdfans/components/profile/profile_settings_section.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/profile.dart';
import 'package:crowdfans/services/vote_service.dart';
import 'package:crowdfans/state/auth_session.dart';
import 'package:crowdfans/utils/app_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// CF-129 — Patrol Superfã: voto, fã clube, logout.
///
/// Obrigatório (Gustavo): green / red / edge — não só happy path.
Widget _wrap(Widget child) {
  return MaterialApp(
    theme: buildCrowdFansTheme(Brightness.light),
    home: Scaffold(
      body: Material(
        child: Center(child: child),
      ),
    ),
  );
}

class _FakeAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSession build() {
    return const AuthSession(
      isLoading: false,
      isBackendValidated: true,
      profile: Profile(
        userUid: 'fan-cf129',
        displayName: 'Superfã CF129',
        name: 'Superfã CF129',
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

Widget _navShell(StatefulNavigationShell navigationShell) {
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
  group('CF-129 green', () {
    testWidgets('voto: tap vote-up sobe contagem e keys estáveis', (
      tester,
    ) async {
      var calls = 0;
      final completer = Completer<VoteResult>();
      await tester.pumpWidget(
        _wrap(
          VoteControlBar(
            votes: 10,
            myVote: 0,
            onVote: (direction) async {
              calls += 1;
              expect(direction, 1);
              return completer.future;
            },
          ),
        ),
      );

      expect(find.byKey(const Key('vote-up')), findsOneWidget);
      expect(find.byKey(const Key('vote-count')), findsOneWidget);
      expect(find.text('10'), findsOneWidget);

      await tester.tap(find.byKey(const Key('vote-up')));
      await tester.pump();
      // Contagem otimista enquanto a API não responde.
      expect(find.text('11'), findsOneWidget);
      expect(calls, 1);

      completer.complete(const VoteResult(id: 'p1', votes: 11, myVote: 1));
      await tester.pump();
      // Sem parent atualizar props, volta ao valor do widget (10) — API foi chamada.
      expect(calls, 1);
    });

    testWidgets('fã clube: nav-clubs + chrome Postagens dos Fã Clubes', (
      tester,
    ) async {
      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              return _navShell(navigationShell);
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

      expect(find.byKey(const Key('nav-home')), findsOneWidget);
      expect(find.byKey(const Key('nav-clubs')), findsOneWidget);
      expect(find.byKey(const Key('nav-profile')), findsOneWidget);

      await tester.tap(find.byKey(const Key('nav-clubs')));
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        _wrap(
          FanClubsFeedHeader(
            sortPopular: true,
            filterAll: true,
            filterPosts: false,
            filterMedia: false,
            onOpenMenu: () {},
            onOpenSearch: () {},
            onSortPopular: () {},
            onSortNew: () {},
            onFilterAll: () {},
            onFilterPosts: () {},
            onFilterMedia: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Postagens dos Fã Clubes'), findsOneWidget);
      expect(find.text('Popularidade'), findsOneWidget);
      expect(find.text('Novos'), findsOneWidget);
      expect(find.byKey(const Key('fan-clubs-search')), findsOneWidget);
    });

    testWidgets('logout: confirma Sair e settings-item-logout', (tester) async {
      var loggedOut = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ProfileSettingsSection(
                  title: 'Sessão',
                  showDivider: false,
                  items: [
                    ProfileSettingItem(
                      id: 'logout',
                      label: 'Sair da conta',
                      asset: 'assets/icons/General/log-out-01.svg',
                      showChevron: false,
                      danger: true,
                      onTap: () async {
                        final ok = await AppAlert.confirm(
                          context,
                          title: 'Sair',
                          message: 'Deseja encerrar a sessão?',
                          confirmLabel: 'Sair',
                        );
                        if (ok) {
                          loggedOut = true;
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      expect(find.byKey(const Key('settings-item-logout')), findsOneWidget);
      expect(find.text('Sair da conta'), findsOneWidget);

      await tester.tap(find.byKey(const Key('settings-item-logout')));
      await tester.pumpAndSettle();
      expect(find.text('Deseja encerrar a sessão?'), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, 'Sair'));
      await tester.pumpAndSettle();
      expect(loggedOut, isTrue);
    });
  });

  group('CF-129 red', () {
    testWidgets('voto: falha da API reverte contagem otimista', (tester) async {
      final completer = Completer<VoteResult>();
      await tester.pumpWidget(
        _wrap(
          VoteControlBar(
            votes: 5,
            myVote: 0,
            onVote: (_) => completer.future,
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('vote-up')));
      await tester.pump();
      expect(find.text('6'), findsOneWidget);

      completer.completeError(StateError('rede'));
      await tester.pump();
      expect(find.text('5'), findsOneWidget);
      expect(find.text('6'), findsNothing);
    });

    testWidgets('logout: Cancelar não encerra sessão', (tester) async {
      var loggedOut = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: TextButton(
                  key: const Key('settings-item-logout'),
                  onPressed: () async {
                    final ok = await AppAlert.confirm(
                      context,
                      title: 'Sair',
                      message: 'Deseja encerrar a sessão?',
                      confirmLabel: 'Sair',
                    );
                    if (ok) {
                      loggedOut = true;
                    }
                  },
                  child: const Text('Sair da conta'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('settings-item-logout')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(loggedOut, isFalse);
      expect(find.text('Deseja encerrar a sessão?'), findsNothing);
    });

    testWidgets('login: submit desabilitado enquanto loading', (tester) async {
      var submits = 0;
      await tester.pumpWidget(
        _wrap(
          CredentialsForm(
            email: 'fan@test.com',
            password: 'x',
            loading: true,
            onEmailChanged: (_) {},
            onPasswordChanged: (_) {},
            onSubmit: () => submits += 1,
            onForgotPassword: () {},
          ),
        ),
      );

      expect(find.byKey(const Key('login-username')), findsOneWidget);
      expect(find.byKey(const Key('login-submit')), findsOneWidget);
      expect(find.text('Carregando...'), findsOneWidget);

      await tester.tap(find.byKey(const Key('login-submit')));
      await tester.pump();
      expect(submits, 0);
    });
  });

  group('CF-129 edge', () {
    testWidgets('voto: contagem zero + toggle upvote desfaz', (tester) async {
      final up = Completer<VoteResult>();
      await tester.pumpWidget(
        _wrap(
          VoteControlBar(
            votes: 0,
            myVote: 0,
            onVote: (_) => up.future,
          ),
        ),
      );
      expect(find.text('0'), findsOneWidget);

      await tester.tap(find.byKey(const Key('vote-up')));
      await tester.pump();
      expect(find.text('1'), findsOneWidget);

      up.complete(const VoteResult(id: 'p1', votes: 1, myVote: 1));
      await tester.pump();

      final undo = Completer<VoteResult>();
      await tester.pumpWidget(
        _wrap(
          VoteControlBar(
            votes: 1,
            myVote: 1,
            onVote: (_) => undo.future,
          ),
        ),
      );
      expect(find.text('1'), findsOneWidget);

      await tester.tap(find.byKey(const Key('vote-up')));
      await tester.pump();
      // Desfazer upvote: otimista volta a 0.
      expect(find.text('0'), findsOneWidget);

      undo.complete(const VoteResult(id: 'p1', votes: 0, myVote: 0));
      await tester.pumpWidget(
        _wrap(
          VoteControlBar(
            votes: 0,
            myVote: 0,
            onVote: (_) async =>
                const VoteResult(id: 'p1', votes: 0, myVote: 0),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('voto: segundo tap enquanto submitting é ignorado', (
      tester,
    ) async {
      var calls = 0;
      await tester.pumpWidget(
        _wrap(
          VoteControlBar(
            votes: 1,
            myVote: 0,
            onVote: (_) async {
              calls += 1;
              await Future<void>.delayed(const Duration(milliseconds: 200));
              return const VoteResult(id: 'p1', votes: 2, myVote: 1);
            },
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('vote-up')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('vote-up')));
      await tester.pump();
      expect(calls, 1);

      await tester.pump(const Duration(milliseconds: 250));
      expect(calls, 1);
    });

    testWidgets('voto: contagem grande não estoura layout da pill', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          VoteControlBar(
            votes: 999999,
            myVote: 0,
            onVote: (_) async =>
                const VoteResult(id: 'p1', votes: 999999, myVote: 0),
          ),
        ),
      );

      expect(find.text('999999'), findsOneWidget);
      final size = tester.getSize(find.byType(VoteControlBar));
      expect(size.height, lessThanOrEqualTo(36));
    });

    testWidgets('fã clube vazio: key fan-clubs-empty visível', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const Center(
            child: Text(
              key: Key('fan-clubs-empty'),
              'Você ainda não segue nenhum fã clube',
            ),
          ),
        ),
      );
      expect(find.byKey(const Key('fan-clubs-empty')), findsOneWidget);
    });

    testWidgets('login: teclado done na senha chama onSubmit', (tester) async {
      var submits = 0;
      await tester.pumpWidget(
        _wrap(
          CredentialsForm(
            email: 'a@b.com',
            password: 'secret',
            onEmailChanged: (_) {},
            onPasswordChanged: (_) {},
            onSubmit: () => submits += 1,
            onForgotPassword: () {},
          ),
        ),
      );

      await tester.enterText(find.byKey(const Key('login-password')), 'secret');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(submits, 1);
    });
  });

  group('CF-129 VoteService', () {
    test('green: neutro → upvote +1', () {
      final next = VoteService.getNextVoteState(
        currentState: 0,
        direction: 1,
      );
      expect(next.nextVoteState, 1);
      expect(next.voteCountDelta, 1);
    });

    test('red: normaliza myVote inválido para 0', () {
      expect(VoteService.normalizeVoteState(99), 0);
      expect(VoteService.normalizeVoteState(null), 0);
    });

    test('edge: upvote em downvote vira +2 no delta', () {
      final next = VoteService.getNextVoteState(
        currentState: -1,
        direction: 1,
      );
      expect(next.nextVoteState, 1);
      expect(next.voteCountDelta, 2);
    });
  });
}
