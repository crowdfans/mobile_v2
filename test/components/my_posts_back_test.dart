import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/screens/post/my_posts_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  test('fallback de voltar em Meus posts é a home', () {
    expect(myPostsBackFallbackRoute, Pages.home);
  });

  testWidgets('Meus posts mostra botão voltar mesmo sem histórico', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: Pages.myPosts,
      routes: [
        GoRoute(
          path: Pages.home,
          builder: (context, state) =>
              const Scaffold(body: Text('home-screen')),
        ),
        GoRoute(
          path: Pages.myPosts,
          builder: (context, state) => const MyPostsScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        theme: buildCrowdFansTheme(Brightness.light),
        routerConfig: router,
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('my-posts-back')), findsOneWidget);
  });
}
