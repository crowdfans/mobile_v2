import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:crowdfans/screens/post/create_post_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

Future<void> pumpCreatePost(
  WidgetTester tester, {
  String? postId,
  String? targetArtistId,
}) async {
  final router = GoRouter(
    initialLocation: '/post/create',
    routes: [
      GoRoute(
        path: '/post/create',
        builder: (context, state) => CreatePostScreen(
          postId: postId,
          targetArtistId: targetArtistId,
        ),
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
}

void main() {
  group('CF-141 green — tipo derivado + UX descrição/mídia', () {
    test('texto sem mídia → text; com imagem → image; com música → membership', () {
      expect(resolveCreatePostType(hasMedia: false), PostType.text);
      expect(resolveCreatePostType(hasMedia: true), PostType.image);
      expect(
        resolveCreatePostType(hasMedia: false, hasMusic: true),
        PostType.membership,
      );
      expect(
        resolveCreatePostType(hasMedia: true, hasMusic: true),
        PostType.image,
      );
    });

    test('pode publicar com descrição ou mídia válida', () {
      expect(
        canPublishCreatePost(text: 'olá', hasMedia: false, hasMusic: false),
        isTrue,
      );
      expect(
        canPublishCreatePost(text: '', hasMedia: true, hasMusic: false),
        isTrue,
      );
      expect(
        canPublishCreatePost(text: '  ', hasMedia: false, hasMusic: true),
        isTrue,
      );
    });

    test('canPublishCreatePost green/red/edge (CF-128 compat)', () {
      expect(canPublishCreatePost(text: 'ok', hasMedia: false), isTrue);
      expect(canPublishCreatePost(text: '', hasMedia: false), isFalse);
      expect(canPublishCreatePost(text: 'a' * 281, hasMedia: false), isFalse);
      expect(canPublishCreatePost(text: '', hasMedia: true), isTrue);
    });

    testWidgets('mostra descrição e botões adicionar imagem/música, sem chips de tipo', (
      tester,
    ) async {
      await pumpCreatePost(tester);

      expect(find.text('Criar Post'), findsOneWidget);
      expect(find.textContaining('descrição'), findsOneWidget);
      expect(find.byKey(const Key('create-post-content')), findsOneWidget);
      expect(find.byKey(const Key('create-post-add-image')), findsOneWidget);
      expect(find.byKey(const Key('create-post-add-music')), findsOneWidget);
      expect(find.text('Adicionar imagem'), findsOneWidget);
      expect(find.text('Adicionar música'), findsOneWidget);
      expect(find.text('Tipo de Post'), findsNothing);
      expect(find.text('Texto'), findsNothing);
      expect(find.text('Imagem'), findsNothing);
    });
  });

  group('CF-141 red — bloqueios', () {
    test('vazio sem mídia não publica', () {
      expect(
        canPublishCreatePost(text: '', hasMedia: false, hasMusic: false),
        isFalse,
      );
      expect(
        canPublishCreatePost(text: '   ', hasMedia: false, hasMusic: false),
        isFalse,
      );
    });

    test('texto >280 é inválido', () {
      final long = 'a' * 281;
      expect(
        validateCreatePost(text: long, hasMedia: false, hasMusic: false),
        'O post pode ter no máximo 280 caracteres',
      );
      expect(
        canPublishCreatePost(text: long, hasMedia: true, hasMusic: false),
        isFalse,
      );
    });

    test('vazio sem mídia devolve erro de conteúdo', () {
      expect(
        validateCreatePost(text: '', hasMedia: false, hasMusic: false),
        'Escreva um texto ou adicione uma imagem ou música',
      );
    });

    testWidgets('Publicar desabilitado quando formulário vazio', (tester) async {
      await pumpCreatePost(tester);

      final button = tester.widget<FilledButton>(
        find.descendant(
          of: find.byKey(const Key('create-post-submit')),
          matching: find.byType(FilledButton),
        ),
      );
      expect(button.onPressed, isNull);
    });
  });

  group('CF-141 edge — limites e mídia', () {
    test('exatamente 280 caracteres é válido', () {
      final exact = 'b' * 280;
      expect(
        validateCreatePost(text: exact, hasMedia: false, hasMusic: false),
        isNull,
      );
      expect(
        canPublishCreatePost(text: exact, hasMedia: false, hasMusic: false),
        isTrue,
      );
    });

    test('imagem tem prioridade sobre música no tipo da API', () {
      expect(
        resolveCreatePostType(hasMedia: true, hasMusic: true),
        PostType.image,
      );
    });

    testWidgets('contador e teclado: lista dispensa teclado no drag', (
      tester,
    ) async {
      await pumpCreatePost(tester);

      final list = tester.widget<ListView>(find.byType(ListView));
      expect(
        list.keyboardDismissBehavior,
        ScrollViewKeyboardDismissBehavior.onDrag,
      );

      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('create-post-content')),
          matching: find.byType(TextField),
        ),
        'oi',
      );
      await tester.pump();
      expect(find.text('2/280'), findsOneWidget);
    });

    testWidgets('tocar Adicionar música marca mídia musical sem chip de tipo', (
      tester,
    ) async {
      await pumpCreatePost(tester);

      await tester.ensureVisible(find.byKey(const Key('create-post-add-music')));
      await tester.tap(find.byKey(const Key('create-post-add-music')));
      await tester.pump();

      expect(find.byKey(const Key('create-post-clear-music')), findsOneWidget);
      expect(find.textContaining('Música'), findsWidgets);
      expect(find.text('Tipo de Post'), findsNothing);
    });
  });
}
