import 'package:crowdfans/components/fan_club/fan_club_post_options_sheet.dart';
import 'package:crowdfans/components/fan_club/fan_club_post_save_memory_button.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

FeedPost _samplePost() {
  return const FeedPost(
    id: 'cf227-lari-bh',
    type: PostType.image,
    author: 'Lari Rocha',
    handle: 'fan/larirocha',
    minutesAgo: 60,
    avatarUri: '',
    text:
        'Saí do trabalho e fui direto pra fila. Trouxe brinde pro pessoal do fã clube de BH.',
    votes: 88,
    comments: 14,
    shares: 5,
    artistId: 'mock-fc-lais',
  );
}

void main() {
  testWidgets(
    'CF-227 menu do post do fã-clube sem ações de perfil de artista',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: Stack(
              children: [
                FanClubPostOptionsSheet(
                  visible: true,
                  post: _samplePost(),
                  artistId: 'mock-fc-lais',
                  onClose: () {},
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Salvar Post nas Memórias'), findsOneWidget);
      expect(find.text('Copiar Link'), findsOneWidget);
      expect(find.text('WhatsApp'), findsOneWidget);
      expect(find.text('Stories'), findsOneWidget);
      expect(find.text('Favoritar Fã Clube'), findsOneWidget);
      expect(find.text('Reportar'), findsOneWidget);

      // Evitar menu de perfil/artista (home feed).
      expect(find.text('Ver Fã Clube'), findsNothing);
      expect(find.text('Ver Fã Clube do Artista'), findsNothing);
      expect(find.text('Deixar de seguir'), findsNothing);
      expect(find.text('Sobre'), findsNothing);
      expect(find.text('Sobre este artista'), findsNothing);
      expect(find.text('Favoritar'), findsNothing);
      expect(find.text('Favoritar Artista'), findsNothing);
    },
  );

  testWidgets(
    'CF-227 Memórias: estrela centralizada acima do rótulo (print)',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: const Scaffold(
            body: Center(
              child: SizedBox(
                width: 360,
                child: FanClubPostSaveMemoryButton(onPressed: _noop),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final star = find.byType(Image);
      final label = find.text('Salvar Post nas Memórias');
      expect(star, findsOneWidget);
      expect(label, findsOneWidget);

      final starCenter = tester.getCenter(star);
      final labelCenter = tester.getCenter(label);
      expect(
        (starCenter.dx - labelCenter.dx).abs(),
        lessThan(8),
        reason: 'estrela e texto devem compartilhar o mesmo eixo X (coluna)',
      );
      expect(
        starCenter.dy,
        lessThan(labelCenter.dy),
        reason: 'estrela acima do texto',
      );
    },
  );

  test(
    'CF-227 fixture Laís Costa inclui post Lari Rocha do print',
    () {
      expect(CfTempMocks.useFanClubFixtures, isFalse);
      expect(kUseCf227FanClubPostMenuFixtures, isFalse);

      final feed = cfTempMockArtistFanClubFeed(cfTempMockLaisArtistUid);
      expect(feed.fanClub.artistName, 'Laís Costa');
      expect(feed.posts, isNotEmpty);
      final post = feed.posts.first;
      expect(post.postId, 'cf227-lari-bh');
      expect(post.authorName, 'Lari Rocha');
      expect(post.authorHandle, 'fan/larirocha');
      expect(
        post.content,
        contains('Trouxe brinde pro pessoal do fã clube de BH'),
      );
      expect(post.imageUrl, isNotEmpty);
    },
  );
}

void _noop() {}
