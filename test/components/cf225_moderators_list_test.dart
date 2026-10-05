import 'package:crowdfans/components/fan_club/fan_club_moderator_preview_row.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/screens/fan_clubs/fan_club_moderators_screen.dart';
import 'package:crowdfans/services/fan_club_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CF-225 fixtures: Enzo + 3 moderadores com fan/handle', () {
    expect(kUseCf225ModeratorsMocks, isFalse);
    final club = cfTempMockArtistFanClubFeed('mock-fc-enzo').fanClub;
    expect(club.artistName, 'Enzo Lima');
    expect(club.viewerIsOwner, isFalse);
    expect(
      club.moderators.map((m) => m.displayName).toList(),
      ['Aline Duarte', 'Maria Eduarda', 'Lari Rocha'],
    );
    expect(
      club.moderators.map((m) => m.handle).toList(),
      ['alineduarte', 'mariaeduarda', 'larirocha'],
    );
    expect(club.moderators.every((m) => m.photoUrl.isNotEmpty), isTrue);
  });

  testWidgets('CF-225 linha de moderador quebra nome longo (sem ellipsis)', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: SizedBox(
            width: 280,
            child: FanClubModeratorPreviewRow(
              moderator: const FanClubModerator(
                userUid: 'u1',
                handle: 'nomemuitolongo',
                displayName:
                    'Maria Eduarda da Silva Santos Oliveira Extra Longo',
                photoUrl: '',
                role: 'moderator',
              ),
            ),
          ),
        ),
      ),
    );

    final name = tester.widget<Text>(find.textContaining('Maria Eduarda'));
    expect(name.softWrap, isTrue);
    expect(name.maxLines, isNull);
    expect(name.overflow, isNot(TextOverflow.ellipsis));
    expect(find.text('fan/nomemuitolongo'), findsOneWidget);
  });

  testWidgets('CF-225 tela: intro Enzo + lista Aline/Maria/Lari', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: const FanClubModeratorsScreen(
          artistId: 'mock-fc-enzo',
          artistName: 'Enzo Lima',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Moderadores'), findsOneWidget);
    expect(
      find.text('Esses fãs ajudam a cuidar do fã-clube de Enzo Lima.'),
      findsOneWidget,
    );
    expect(find.text('Aline Duarte'), findsOneWidget);
    expect(find.text('fan/alineduarte'), findsOneWidget);
    expect(find.text('Maria Eduarda'), findsOneWidget);
    expect(find.text('fan/mariaeduarda'), findsOneWidget);
    expect(find.text('Lari Rocha'), findsOneWidget);
    expect(find.text('fan/larirocha'), findsOneWidget);
    // Print superfã: sem ferramentas de dono.
    expect(find.text('Remover'), findsNothing);
    expect(find.text('Adicionar moderador (userUid)'), findsNothing);
    expect(find.text('Pedidos pendentes'), findsNothing);
  });
}
