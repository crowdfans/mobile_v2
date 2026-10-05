import 'package:crowdfans/components/post/post_card.dart';
import 'package:crowdfans/components/post/post_video_preview.dart';
import 'package:crowdfans/components/post/post_video_preview_chrome.dart';
import 'package:crowdfans/components/post/post_video_ui_state.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:crowdfans/services/home_feed_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: buildCrowdFansTheme(Brightness.light),
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  test('CF-232 fixture: Banda Uelo vídeo público (print)', () {
    expect(CfTempMocks.useHomeFeedFixtures, isTrue);
    final post = cfTempMockHomeFeedPosts().firstWhere(
      (p) => p.id == 'cf232-uelo-video',
    );
    expect(post.type, PostType.video);
    expect(post.author, 'Banda Uelo');
    expect(post.handle, '@bandauelo');
    expect(post.rank, '#18');
    expect(post.minutesAgo, 31);
    expect(post.text, contains('passagem de som'));
    expect(post.votes, 136);
    expect(post.comments, 31);
    expect(post.shares, 11);
    expect(post.videoDuration, '00:00');
    expect((post.videoUri ?? '').isEmpty, isTrue);
  });

  test('CF-232: HomeFeedService devolve fixture Uelo', () async {
    final dto = await HomeFeedService.load(page: 1);
    expect(
      dto.feedPosts.any((p) => p.id == 'cf232-uelo-video'),
      isTrue,
    );
  });

  /// GREEN — loaded / idle alinhado ao print (play-slash + mute + 00:00).
  testWidgets('CF-232 green: idle carregado com play-slash, mute e 00:00', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const PostVideoPreviewChrome(
          state: PostVideoUiState.idle,
          muted: true,
          playing: false,
          durationLabel: '00:00',
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('post-video-play')), findsOneWidget);
    expect(find.byIcon(Icons.play_disabled_rounded), findsOneWidget);
    expect(find.byIcon(Icons.volume_off_rounded), findsOneWidget);
    expect(find.byKey(const Key('post-video-duration')), findsOneWidget);
    expect(find.text('00:00'), findsOneWidget);
    expect(find.byKey(const Key('post-video-buffering')), findsNothing);
    expect(find.byKey(const Key('post-video-error')), findsNothing);
  });

  testWidgets('CF-232 green: PostMedia + card Uelo print', (tester) async {
    final post = cfTempMockHomeFeedPosts().firstWhere(
      (p) => p.id == 'cf232-uelo-video',
    );

    await tester.pumpWidget(
      _wrap(PostCard(post: post)),
    );
    await tester.pump();

    expect(find.text('Banda Uelo'), findsOneWidget);
    expect(find.text('@bandauelo'), findsOneWidget);
    expect(find.text('#18'), findsOneWidget);
    expect(find.textContaining('passagem de som'), findsOneWidget);
    expect(find.textContaining('31 minutos atrás'), findsOneWidget);
    expect(find.text('136'), findsOneWidget);
    expect(find.text('31'), findsOneWidget); // comments
    expect(find.text('11'), findsOneWidget); // shares
    expect(find.byType(PostVideoPreview), findsOneWidget);
    expect(find.byIcon(Icons.play_disabled_rounded), findsOneWidget);
    expect(find.byIcon(Icons.volume_off_rounded), findsOneWidget);
    expect(find.text('00:00'), findsOneWidget);
  });

  /// RED — URL vazia / indisponível → erro distinto (não bloqueio comercial).
  testWidgets('CF-232 red: vídeo vazio abre estado de erro', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const PostVideoPreview(
          videoUri: '',
          duration: '00:00',
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('post-video-play')));
    await tester.pump();

    expect(find.byKey(const Key('post-video-error')), findsOneWidget);
    expect(find.text('Vídeo indisponível.'), findsOneWidget);
    expect(find.text('Tentar de novo'), findsOneWidget);
    expect(find.byIcon(Icons.play_disabled_rounded), findsOneWidget);
    expect(find.text('Assinar Membership +'), findsNothing);
  });

  /// EDGE — buffering / loading: spinner, sem play central.
  testWidgets('CF-232 edge: buffering mostra spinner sem play', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const PostVideoPreviewChrome(
          state: PostVideoUiState.buffering,
          muted: true,
          playing: true,
          durationLabel: '00:12',
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('post-video-buffering')), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byKey(const Key('post-video-play')), findsNothing);
    expect(find.byKey(const Key('post-video-error')), findsNothing);
    expect(find.text('00:12'), findsOneWidget);
    expect(find.byIcon(Icons.volume_off_rounded), findsOneWidget);
  });

  testWidgets('CF-232 edge: loading também usa chrome de buffering', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const PostVideoPreviewChrome(
          state: PostVideoUiState.loading,
          muted: true,
          playing: false,
          durationLabel: '00:00',
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('post-video-buffering')), findsOneWidget);
    expect(find.byKey(const Key('post-video-play')), findsNothing);
  });
}
