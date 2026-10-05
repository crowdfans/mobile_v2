import 'package:crowdfans/components/post/post_media_lightbox.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CF-234: fixture deer-first com 3 URIs (print 1/3)', () {
    final uris = cfTempMockCf234LightboxUris();
    expect(uris, hasLength(3));
    expect(uris.first, contains('1484406566174')); // Unsplash deer
    expect(CfTempMocks.useHomeFeedFixtures, isFalse); // demock GET /home
    final carousel = cfTempMockHomeFeedPosts().firstWhere(
      (p) => p.id == 'cf233-ponzanelli-carousel',
    );
    expect(carousel.carouselUris.length, greaterThanOrEqualTo(3));
  });

  testWidgets('CF-234: Fechar + 1/3 na área segura, sem pill', (tester) async {
    final uris = cfTempMockCf234LightboxUris();
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          padding: EdgeInsets.only(top: 47, bottom: 34),
          size: Size(390, 844),
        ),
        child: MaterialApp(
          home: PostMediaLightbox(uris: uris),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Fechar'), findsOneWidget);
    expect(find.text('1/3'), findsOneWidget);

    // Print: índice é Text puro (sem DecoratedBox pill atrás).
    final indexText = find.text('1/3');
    expect(
      find.ancestor(of: indexText, matching: find.byType(DecoratedBox)),
      findsNothing,
    );

    final fechar = tester.getTopLeft(find.text('Fechar'));
    expect(fechar.dy, greaterThanOrEqualTo(47));
    expect(fechar.dx, greaterThan(200));

    final index = tester.getCenter(indexText);
    expect(index.dx, closeTo(195, 40));
    expect(index.dy, greaterThan(700));

    await tester.tap(find.text('Fechar'));
    await tester.pumpAndSettle();
  });

  testWidgets('CF-234: índice acompanha initialIndex 1 → 2/3', (tester) async {
    final uris = cfTempMockCf234LightboxUris();
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          padding: EdgeInsets.only(top: 47, bottom: 34),
          size: Size(390, 844),
        ),
        child: MaterialApp(
          home: PostMediaLightbox(uris: uris, initialIndex: 1),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('2/3'), findsOneWidget);
  });

  testWidgets('CF-234: índice acompanha initialIndex 2 → 3/3', (tester) async {
    final uris = cfTempMockCf234LightboxUris();
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          padding: EdgeInsets.only(top: 47, bottom: 34),
          size: Size(390, 844),
        ),
        child: MaterialApp(
          home: PostMediaLightbox(uris: uris, initialIndex: 2),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('3/3'), findsOneWidget);
  });

  testWidgets('CF-234: reduzir movimento remove InteractiveViewer', (
    tester,
  ) async {
    final uris = cfTempMockCf234LightboxUris();
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          padding: EdgeInsets.only(top: 47, bottom: 34),
          size: Size(390, 844),
          disableAnimations: true,
        ),
        child: MaterialApp(
          home: PostMediaLightbox(uris: uris),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(InteractiveViewer), findsNothing);
    expect(find.text('Fechar'), findsOneWidget);
    expect(find.text('1/3'), findsOneWidget);
  });

  testWidgets('CF-234: open() empurra rota opaca preta', (tester) async {
    final uris = cfTempMockCf234LightboxUris();
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: TextButton(
                onPressed: () => PostMediaLightbox.open(context, uris: uris),
                child: const Text('Abrir'),
              ),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    expect(find.text('Fechar'), findsOneWidget);
    expect(find.text('1/3'), findsOneWidget);
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).last);
    expect(scaffold.backgroundColor, Colors.black);
  });
}
