import 'package:crowdfans/components/fan_club/fan_club_post_options_sheet.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

FeedPost _samplePost() {
  return const FeedPost(
    id: 'post-1',
    type: PostType.text,
    author: 'Lari Rocha',
    handle: 'fan/larirocha',
    minutesAgo: 60,
    avatarUri: '',
    text: 'Texto do post',
    votes: 0,
    comments: 0,
    shares: 0,
    artistId: 'artist-1',
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
                  artistId: 'artist-1',
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

      expect(find.text('Ver Fã Clube'), findsNothing);
      expect(find.text('Deixar de seguir'), findsNothing);
      expect(find.text('Sobre'), findsNothing);
      expect(find.text('Favoritar'), findsNothing);
    },
  );
}
