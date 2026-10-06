import 'package:crowdfans/components/post/post_share_sheet.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CF-236: share sheet sem título; Stories SVG; ícone share', (
    tester,
  ) async {
    const post = FeedPost(
      id: 'p1',
      type: PostType.text,
      author: 'Gus',
      handle: '@gus',
      minutesAgo: 1,
      avatarUri: '',
      text: 'oi',
      votes: 0,
      comments: 0,
      shares: 0,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: PostShareSheet(
            visible: true,
            post: post,
            onClose: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Copiar Link'), findsOneWidget);
    expect(find.text('WhatsApp'), findsOneWidget);
    expect(find.text('Stories'), findsOneWidget);
    expect(find.text('Compartilhar para...'), findsOneWidget);
    // Título visual removido (print); label só em Semantics.
    expect(find.text('Compartilhar'), findsNothing);
    expect(find.byIcon(Icons.ios_share), findsOneWidget);
    expect(find.byIcon(Icons.reply_rounded), findsNothing);
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is SvgPicture &&
            w.bytesLoader.toString().contains('instagram.svg'),
      ),
      findsOneWidget,
    );
  });
}
