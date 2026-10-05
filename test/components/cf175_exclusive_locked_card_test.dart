import 'package:crowdfans/components/feed/exclusive_feed_card.dart';
import 'package:crowdfans/components/feed/exclusive_feed_card_locked_content.dart';
import 'package:crowdfans/components/post/post_card.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: buildCrowdFansTheme(Brightness.light),
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

FeedPost _lockedPost({
  String handle = '@kheperrrr',
  String author = 'Kheper',
  String id = 'cf175-kheper-locked',
}) {
  return FeedPost(
    id: id,
    type: PostType.text,
    author: author,
    artistId: 'mock-fc-kheper',
    handle: handle,
    minutesAgo: 19,
    avatarUri: '',
    text: 'Bastidores exclusivos.',
    votes: 110,
    comments: 21,
    shares: 7,
    isExclusive: true,
    exclusiveLocked: true,
  );
}

void main() {
  // --- GREEN (print / sucesso) ---
  testWidgets(
    'CF-175 green: único card + CTA contornado + autor fora; sem moldura lilás',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          ExclusiveFeedCard(
            post: _lockedPost(),
            unlocked: false,
            onPressUnlock: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Kheper'), findsOneWidget);
      expect(find.text('@kheperrrr'), findsOneWidget);
      expect(find.text('Exclusivo'), findsOneWidget);
      expect(find.text('Conteúdo para membros'), findsOneWidget);
      expect(
        find.text(
          'Assine o membership de kheperrrr para liberar posts exclusivos.',
        ),
        findsOneWidget,
      );
      expect(find.text('Assinar Membership +'), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.byType(FilledButton), findsNothing);

      // Autoria fora do card de bloqueio (print).
      final authorY = tester.getTopLeft(find.text('Kheper')).dy;
      final lockY = tester.getTopLeft(find.text('Conteúdo para membros')).dy;
      expect(authorY, lessThan(lockY));

      // PostCard externo sem tint lilás / borda roxa.
      final postCard = tester.widget<PostCard>(find.byType(PostCard));
      expect(postCard.backgroundColor, isNull);
      expect(postCard.borderColor, isNull);

      final outlined = tester.widget<OutlinedButton>(
        find.byType(OutlinedButton),
      );
      final style = outlined.style;
      expect(style?.side?.resolve({})?.color, AppPalette.purple500);
      expect(style?.backgroundColor?.resolve({}), Colors.white);

      // Footer preservado.
      expect(find.text('110'), findsOneWidget);
      expect(find.text('21'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
    },
  );

  test('CF-175 green: fixture Kheper bloqueado no home feed (mocks ON)', () {
    expect(CfTempMocks.useHomeFeedFixtures, isTrue);
    final posts = cfTempMockHomeFeedPosts();
    final locked = posts.firstWhere((p) => p.id == 'cf175-kheper-locked');
    expect(locked.author, 'Kheper');
    expect(locked.handle, '@kheperrrr');
    expect(locked.isExclusive, isTrue);
    expect(locked.exclusiveLocked, isTrue);
    expect(locked.votes, 110);
    expect(locked.comments, 21);
    expect(locked.shares, 7);
    expect(locked.minutesAgo, 19);
    // CF-235 Mayra desbloqueado permanece primeiro — não regressar.
    expect(posts.first.id, 'cf235-mayra-exclusive');
  });

  // --- RED (inválido / bloqueado / vazio) ---
  testWidgets('CF-175 red: CTA desabilitado sem onPressUnlock', (tester) async {
    await tester.pumpWidget(
      _wrap(
        ExclusiveFeedCard(
          post: _lockedPost(),
          unlocked: false,
        ),
      ),
    );
    await tester.pump();

    final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('CF-175 red: handle vazio cai em fallback artista', (tester) async {
    await tester.pumpWidget(
      _wrap(
        ExclusiveFeedCardLockedContent(
          resolvedUsername: exclusiveMembershipUsername(''),
          canUnlock: false,
          onPressUnlock: () {},
        ),
      ),
    );
    await tester.pump();

    expect(
      find.text(
        'Assine o membership de artista para liberar posts exclusivos.',
      ),
      findsOneWidget,
    );
    expect(find.byType(OutlinedButton), findsOneWidget);
    final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
    expect(button.onPressed, isNull);
  });

  // --- EDGE (prefixo artist/, texto longo, fixtures) ---
  test('CF-175 edge: strip @ e artist/ no username do membership', () {
    expect(exclusiveMembershipUsername('@kheperrrr'), 'kheperrrr');
    expect(exclusiveMembershipUsername('artist/gusart'), 'gusart');
    expect(exclusiveMembershipUsername('@artist/gusart'), 'gusart');
    expect(exclusiveMembershipUsername(''), 'artista');
    expect(exclusiveMembershipUsername('   '), 'artista');
  });

  testWidgets(
    'CF-175 edge: handle artist/gusart não aparece no copy; CTA continua contornado',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          ExclusiveFeedCard(
            post: _lockedPost(handle: 'artist/gusart', author: 'Gus Art'),
            unlocked: false,
            onPressUnlock: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.textContaining('artist/gusart'), findsNothing);
      expect(
        find.text(
          'Assine o membership de gusart para liberar posts exclusivos.',
        ),
        findsOneWidget,
      );
      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.byType(FilledButton), findsNothing);
    },
  );

  testWidgets('CF-175 edge: nome longo não quebra o card', (tester) async {
    const long =
        'superfanzinholongusernamecommaisdequarenta_caracteres_xyz';
    await tester.pumpWidget(
      _wrap(
        ExclusiveFeedCardLockedContent(
          resolvedUsername: long,
          canUnlock: true,
          onPressUnlock: () {},
        ),
      ),
    );
    await tester.pump();

    expect(find.textContaining(long), findsOneWidget);
    expect(find.byType(OutlinedButton), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
