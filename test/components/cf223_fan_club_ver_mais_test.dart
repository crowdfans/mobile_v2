import 'package:crowdfans/components/fan_club/fan_club_moderation_candidacy_section.dart';
import 'package:crowdfans/components/fan_club/fan_club_moderator_preview_row.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/screens/fan_clubs/fan_club_about_screen.dart';
import 'package:crowdfans/services/fan_club_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  test('CF-223 fixtures: 3 moderadores do print Enzo + candidatura liberada', () {
    expect(kUseCfTempMocks, isTrue);
    expect(CfTempMocks.useFanClubFixtures, isFalse);

    final club = cfTempMockArtistFanClubFeed('mock-fc-enzo').fanClub;
    expect(club.artistName, 'Enzo Lima');
    expect(club.isMember, isTrue);
    expect(club.viewerIsOwner, isFalse);
    expect(club.viewerIsModerator, isFalse);
    expect(club.viewerIsExpelled, isFalse);
    expect(club.moderators.map((m) => m.displayName), [
      'Aline Duarte',
      'Maria Eduarda',
      'Lari Rocha',
    ]);
    expect(
      club.moderators.map((m) => m.handle),
      ['alineduarte', 'mariaeduarda', 'larirocha'],
    );
    for (final mod in club.moderators) {
      expect(mod.photoUrl, isNotEmpty);
    }
  });

  testWidgets('CF-223 prévia de moderador mostra nome e handle fan/', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: FanClubModeratorPreviewRow(
            moderator: const FanClubModerator(
              userUid: 'u1',
              handle: 'alineduarte',
              displayName: 'Aline Duarte',
              photoUrl: '',
              role: 'moderator',
            ),
          ),
        ),
      ),
    );

    expect(find.text('Aline Duarte'), findsOneWidget);
    expect(find.text('fan/alineduarte'), findsOneWidget);
    expect(find.textContaining('Moderador'), findsNothing);
  });

  testWidgets('CF-223 candidatura tem CTA Solicitar moderação', (tester) async {
    var pressed = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: FanClubModerationCandidacySection(
            onRequestPressed: () => pressed = true,
          ),
        ),
      ),
    );

    expect(find.text('Quero ajudar como moderador(a)'), findsOneWidget);
    await tester.tap(find.text('Solicitar moderação'));
    expect(pressed, isTrue);
  });

  testWidgets(
    'CF-223 Ver mais: lista resumida, Ver todos e candidatura (sem apelação)',
    (tester) async {
      expect(CfTempMocks.useFanClubFixtures, isFalse);

      final router = GoRouter(
        initialLocation: '/about',
        routes: [
          GoRoute(
            path: '/about',
            builder: (context, state) => const FanClubAboutScreen(
              artistId: 'mock-fc-enzo',
              artistName: 'Enzo Lima',
            ),
          ),
          GoRoute(
            path: '/fan-clubs/moderators',
            builder: (context, state) => const SizedBox.shrink(),
          ),
          GoRoute(
            path: '/fan-clubs/request-moderation',
            builder: (context, state) => const SizedBox.shrink(),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          theme: buildCrowdFansTheme(Brightness.light),
          routerConfig: router,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ver mais'), findsOneWidget);
      expect(find.text('Moderadores do fã-clube'), findsOneWidget);
      expect(find.text('Aline Duarte'), findsOneWidget);
      expect(find.text('Maria Eduarda'), findsOneWidget);
      expect(find.text('Lari Rocha'), findsOneWidget);
      expect(find.text('fan/alineduarte'), findsOneWidget);
      expect(find.text('fan/mariaeduarda'), findsOneWidget);
      expect(find.text('fan/larirocha'), findsOneWidget);
      expect(find.text('Ver todos os moderadores'), findsOneWidget);
      expect(find.text('Quero ajudar como moderador(a)'), findsOneWidget);
      expect(find.text('Solicitar moderação'), findsOneWidget);
      expect(find.textContaining('apelar'), findsNothing);
      expect(find.text('Enviar apelação'), findsNothing);
      expect(find.text('Moderação (strikes / expulsões)'), findsNothing);

      final verTodos = tester.widget<FilledButton>(
        find.ancestor(
          of: find.text('Ver todos os moderadores'),
          matching: find.byType(FilledButton),
        ),
      );
      final style = verTodos.style;
      final bg = style?.backgroundColor?.resolve({});
      expect(bg, AppPalette.platinum100);
    },
  );
}
