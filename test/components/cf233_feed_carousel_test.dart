import 'package:crowdfans/components/post/post_carousel.dart';
import 'package:crowdfans/components/post/post_media.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: buildCrowdFansTheme(Brightness.light),
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  testWidgets('CF-233: carrossel com peek, proporção 1:1 e Semantics', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const PostCarousel(
          uris: [
            'https://example.com/a.jpg',
            'https://example.com/b.jpg',
            'https://example.com/c.jpg',
          ],
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('post-carousel')), findsOneWidget);
    expect(find.byKey(const Key('post-carousel-counter')), findsOneWidget);
    expect(find.text('1/3'), findsOneWidget);
    expect(find.byKey(const Key('post-carousel-dots')), findsOneWidget);

    final aspect = tester.widget<AspectRatio>(
      find.byKey(const Key('post-carousel')),
    );
    expect(aspect.aspectRatio, 1);

    final pageView = tester.widget<PageView>(find.byType(PageView));
    expect(pageView.padEnds, isTrue);
    expect(pageView.controller!.viewportFraction, closeTo(0.86, 0.001));

    expect(find.bySemanticsLabel('Imagem 1 de 3'), findsWidgets);
  });

  testWidgets('CF-233: PostMedia usa carrossel para FeedPost Ponzanelli', (
    tester,
  ) async {
    final post = cfTempMockHomeFeedPosts().firstWhere(
      (p) => p.id == 'cf233-ponzanelli-carousel',
    );
    expect(post.type, PostType.carousel);
    expect(post.votes, 240);
    expect(post.comments, 36);
    expect(post.shares, 7);

    await tester.pumpWidget(_wrap(PostMedia(post: post)));
    await tester.pump();

    expect(find.byType(PostCarousel), findsOneWidget);
    expect(find.byKey(const Key('post-carousel')), findsOneWidget);
  });

  test('CF-233: amostra print carrossel ainda disponível (fixtures off)', () {
    expect(CfTempMocks.useHomeFeedFixtures, isFalse); // demock GET /home
    final dto = cfTempMockHomeFeedDto(page: 1);
    final carousel = dto.feedPosts.firstWhere(
      (p) => p.id == 'cf233-ponzanelli-carousel',
    );
    expect(carousel.carouselUris.length, 3);
    expect(carousel.author, 'Ponzanelli');
  });
}
