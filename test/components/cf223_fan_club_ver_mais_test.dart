import 'package:crowdfans/components/fan_club/fan_club_moderation_candidacy_section.dart';
import 'package:crowdfans/components/fan_club/fan_club_moderator_preview_row.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/fan_club_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
}
