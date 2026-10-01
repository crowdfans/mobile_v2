import 'dart:io';

import 'package:crowdfans/constants/pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Regressão do 404 `/artists/<uuid>` (GoException: no routes for location).
void main() {
  testWidgets('GoRouter resolve /artists/:artistId no shell (irmão do feed)', (
    tester,
  ) async {
    const artistId = '01a0a1cf-7f72-7c93-a2ea-bbc777ffce1e';
    String? openedArtistId;

    final router = GoRouter(
      initialLocation: Pages.home,
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return Scaffold(body: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: Pages.home,
                  builder: (context, state) => const SizedBox.expand(),
                ),
                GoRoute(
                  path: Pages.artistProfile,
                  builder: (context, state) {
                    openedArtistId = state.pathParameters['artistId'];
                    return Text('artist:$openedArtistId');
                  },
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: Pages.clubs,
                  builder: (context, state) => const SizedBox.expand(),
                ),
              ],
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    router.go(Pages.artistProfileOf(artistId));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(openedArtistId, artistId);
    expect(find.text('artist:$artistId'), findsOneWidget);
    expect(router.state.uri.path, '/artists/$artistId');
  });

  test('Pages.artistProfileOf gera path /artists/<id>', () {
    const id = '01a0a1cf-7f72-7c93-a2ea-bbc777ffce1e';
    final loc = Pages.artistProfileOf(id, name: 'Ludmilla');
    final uri = Uri.parse(loc);
    expect(uri.path, '/artists/$id');
    expect(uri.queryParameters['name'], 'Ludmilla');
    expect(Pages.artistProfile, '/artists/:artistId');
  });

  test('app_router registra artistProfile como irmão do feed', () {
    final router = File('lib/router/app_router.dart').readAsStringSync();
    expect(router, contains('path: Pages.artistProfile'));
    expect(
      router,
      isNot(contains("path: '/artists/:artistId'")),
      reason: 'não aninhar path absoluto sob /feed',
    );
  });
}
