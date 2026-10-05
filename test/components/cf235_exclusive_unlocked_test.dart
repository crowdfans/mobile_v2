import 'package:crowdfans/components/feed/exclusive_feed_card.dart';
import 'package:crowdfans/components/feed/exclusive_post_meta_row.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CF-235 fixture: Mayra exclusivo desbloqueado no home feed', () {
    expect(CfTempMocks.useHomeFeedFixtures, isFalse); // demock GET /home
    final posts = cfTempMockHomeFeedPosts();
    final exclusive = posts.firstWhere((p) => p.id == 'cf235-mayra-exclusive');
    expect(exclusive.author, 'Mayra');
    expect(exclusive.handle, '@mayra');
    expect(exclusive.rank, '#3');
    expect(exclusive.isExclusive, isTrue);
    expect(exclusive.exclusiveLocked, isFalse);
    expect(exclusive.votes, 201);
    expect(exclusive.comments, 21);
    expect(exclusive.shares, 11);
    expect(
      exclusive.text,
      contains('Versão acústica gravada no camarim'),
    );
    // Print: Mayra é o primeiro card visível do feed.
    expect(posts.first.id, 'cf235-mayra-exclusive');
  });

  testWidgets(
    'CF-235: desbloqueado mostra Exclusivo acima + rank #3 + mídia (sem CTA)',
    (tester) async {
      final post = cfTempMockHomeFeedPosts().firstWhere(
        (p) => p.id == 'cf235-mayra-exclusive',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: SingleChildScrollView(
              child: ExclusiveFeedCard(
                post: post,
                unlocked: true,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(ExclusivePostMetaRow), findsOneWidget);
      expect(find.text('Exclusivo'), findsOneWidget);
      expect(find.text('Disponível para membros'), findsOneWidget);
      expect(find.text('Mayra'), findsOneWidget);
      expect(find.text('@mayra'), findsOneWidget);
      expect(find.text('#3'), findsOneWidget);
      expect(find.textContaining('Versão acústica'), findsOneWidget);
      expect(find.text('201'), findsOneWidget);
      expect(find.text('21'), findsOneWidget);
      expect(find.text('11'), findsOneWidget);
      expect(find.text('Assinar Membership +'), findsNothing);
      expect(find.text('Conteúdo para membros'), findsNothing);

      // Badge acima do header (print Superfã Feed).
      final metaY = tester.getTopLeft(find.byType(ExclusivePostMetaRow)).dy;
      final authorY = tester.getTopLeft(find.text('Mayra')).dy;
      expect(metaY, lessThan(authorY));

      final members = tester.widget<Text>(find.text('Disponível para membros'));
      expect(members.style?.color, AppPalette.purple700);
    },
  );
}
