import 'package:crowdfans/components/fan_club/fan_club_moderator_preview_row.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/fan_club_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CF-225 linha de moderador não corta nome longo', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: SizedBox(
            width: 320,
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

    final name = tester.widget<Text>(
      find.textContaining('Maria Eduarda'),
    );
    expect(name.maxLines, 1);
    expect(name.overflow, TextOverflow.ellipsis);
    expect(find.text('fan/nomemuitolongo'), findsOneWidget);
  });
}
