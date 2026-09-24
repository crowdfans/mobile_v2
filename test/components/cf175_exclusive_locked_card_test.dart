import 'package:crowdfans/components/feed/exclusive_feed_card_locked_content.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CF-175: único card de bloqueio com CTA contornado', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: ExclusiveFeedCardLockedContent(
            resolvedUsername: 'artista',
            canUnlock: true,
            onPressUnlock: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Assinar Membership +'), findsOneWidget);
    expect(find.byType(OutlinedButton), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
    expect(find.text('Conteúdo para membros'), findsOneWidget);
  });
}
