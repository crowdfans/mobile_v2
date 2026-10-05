import 'package:crowdfans/components/fan_letter/fan_letter_canvas_preview.dart';
import 'package:crowdfans/components/profile/artist_profile_letter_tile.dart';
import 'package:crowdfans/components/post/post_avatar.dart';
import 'package:crowdfans/components/profile/profile_state.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/services/fan_letter_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CF-181: tile mostra autoria no topo com avatar e #n', (
    tester,
  ) async {
    final letter = Cf181CartasMock.letters(artistId: 'a1').first;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: SizedBox(
            width: 120,
            height: 160,
            child: ArtistProfileLetterTile(letter: letter, position: 2),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Aline Duarte'), findsOneWidget);
    expect(find.text('#2'), findsOneWidget);
    expect(find.byType(PostAvatar), findsOneWidget);
    expect(find.byType(FanLetterCanvasPreview), findsOneWidget);

    // Print: em carta clara a autoria é escura; night → clara.
    final author = tester.widget<Text>(find.text('Aline Duarte'));
    expect(author.style?.color, Colors.white);
  });

  testWidgets('CF-181: capa clara usa autoria escura', (tester) async {
    const letter = FanLetter(
      id: 'plain',
      artistId: 'a1',
      artistName: 'Art',
      fanDisplayName: 'Caio Loux',
      fanHandle: 'caio',
      fanAvatarUri: '',
      votesCount: 0,
      sendsCount: 0,
      artistUpvoted: false,
      postedAt: 0,
      bodyText: 'SHOW LOTADO',
      backgroundId: 'sky-soft',
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: const Scaffold(
          body: SizedBox(
            width: 120,
            height: 160,
            child: ArtistProfileLetterTile(letter: letter, position: 1),
          ),
        ),
      ),
    );
    await tester.pump();

    final author = tester.widget<Text>(find.text('Caio Loux'));
    expect(author.style?.color, const Color(0xFF1C1C1E));
    expect(find.text('#1'), findsOneWidget);
  });

  testWidgets('CF-181: empty state Cartas em PT (não Fan letters)', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: const Scaffold(
          body: ProfileState(
            title: 'Cartas',
            message: 'Nenhuma carta ainda.',
          ),
        ),
      ),
    );

    expect(find.text('Cartas'), findsOneWidget);
    expect(find.text('Nenhuma carta ainda.'), findsOneWidget);
    expect(find.text('Fan letters'), findsNothing);
    expect(find.textContaining('fan letter'), findsNothing);
  });

  testWidgets('CF-181: grade 3 colunas com posição 1..n', (tester) async {
    final letters = Cf181CartasMock.letters(artistId: 'a1').take(6).toList();
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: GridView.builder(
            itemCount: letters.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 3 / 4,
            ),
            itemBuilder: (context, index) {
              return ArtistProfileLetterTile(
                letter: letters[index],
                position: index + 1,
              );
            },
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Maria Eduarda'), findsOneWidget);
    expect(find.text('João Ribeiro'), findsOneWidget);
    expect(find.text('Anna Lu'), findsOneWidget);
    expect(find.text('#1'), findsOneWidget);
    expect(find.text('#6'), findsOneWidget);
    expect(find.byType(ArtistProfileLetterTile), findsNWidgets(6));
  });
}
