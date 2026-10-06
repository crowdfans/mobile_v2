import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/home/create_menu_sheet.dart';
import 'package:crowdfans/components/input/app_text_field.dart';
import 'package:crowdfans/components/post/create_post_feedback_banner.dart';
import 'package:crowdfans/components/post/my_post_options_sheet.dart';
import 'package:crowdfans/components/post/my_post_row.dart';
import 'package:crowdfans/components/post/my_posts_body.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:crowdfans/models/profile.dart';
import 'package:crowdfans/screens/post/create_post_screen.dart';
import 'package:crowdfans/services/post_service.dart';
import 'package:crowdfans/state/auth_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// CF-130 — green / red / edge do fluxo artista editar / apagar post.
///
/// Patrol E2E (device) fica em `integration_test/e2e_artist_edit_delete_post_test.dart`.
/// Aqui cobrimos keys + gates de UI sem emulador.
void main() {
  UserPost samplePost({
    String id = 'post-cf130',
    String text = 'load-e2e stamp',
  }) {
    return UserPost(
      id: id,
      userId: 'artist-1',
      type: PostType.text,
      text: text,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
  }

  Widget wrap(Widget child) {
    return MaterialApp(
      theme: buildCrowdFansTheme(Brightness.light),
      home: Scaffold(body: child),
    );
  }

  group('CF-130 GREEN', () {
    testWidgets('artista: create-menu-my-posts no menu +', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [authSessionProvider.overrideWith(_ArtistAuth.new)],
          child: MaterialApp(
            theme: buildCrowdFansTheme(Brightness.light),
            home: const _CreateMenuHarness(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('nav-create')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('create-menu-my-posts')), findsOneWidget);
      expect(find.text('Meus posts'), findsOneWidget);
      expect(find.byKey(const Key('create-menu-create-post')), findsOneWidget);
      expect(Pages.myPosts, '/post/mine');
    });

    testWidgets('menu editar/deletar dispara callbacks', (tester) async {
      var edited = false;
      var deleted = false;
      await tester.pumpWidget(
        wrap(
          MyPostOptionsSheet(
            visible: true,
            onClose: () {},
            onEdit: () => edited = true,
            onDelete: () => deleted = true,
          ),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('my-posts-edit')), findsOneWidget);
      expect(find.byKey(const Key('my-posts-delete')), findsOneWidget);

      await tester.tap(find.byKey(const Key('my-posts-edit')));
      await tester.pump();
      expect(edited, isTrue);

      await tester.tap(find.byKey(const Key('my-posts-delete')));
      await tester.pump();
      expect(deleted, isTrue);
    });

    testWidgets('my-posts-item-menu abre callback na row', (tester) async {
      var opened = false;
      await tester.pumpWidget(
        wrap(
          MyPostRow(
            post: samplePost(),
            onOpenMenu: () => opened = true,
          ),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('my-posts-item-menu')), findsOneWidget);
      await tester.tap(find.byKey(const Key('my-posts-item-menu')));
      await tester.pump();
      expect(opened, isTrue);
      expect(find.text('load-e2e stamp'), findsOneWidget);
    });

    test('canPublishCreatePost permite editar texto válido', () {
      expect(
        canPublishCreatePost(text: 'editado ok', hasMedia: false),
        isTrue,
      );
    });

    testWidgets('create-post-submit habilitado no edit com texto', (
      tester,
    ) async {
      var pressed = false;
      await tester.pumpWidget(
        wrap(
          AppButton(
            key: const Key('create-post-submit'),
            label: 'Atualizar Post',
            disabled: !canPublishCreatePost(
              text: 'editado stamp',
              hasMedia: false,
            ),
            onPressed: () => pressed = true,
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.byKey(const Key('create-post-submit')));
      await tester.pump();
      expect(pressed, isTrue);
    });
  });

  group('CF-130 RED', () {
    test('canPublishCreatePost bloqueia vazio e overflow', () {
      expect(canPublishCreatePost(text: '', hasMedia: false), isFalse);
      expect(canPublishCreatePost(text: '   ', hasMedia: false), isFalse);
      expect(canPublishCreatePost(text: 'a' * 281, hasMedia: false), isFalse);
    });

    testWidgets('RED: lista em erro de rede oferece Tentar Novamente', (
      tester,
    ) async {
      var retried = false;
      await tester.pumpWidget(
        wrap(
          MyPostsBody(
            loading: false,
            error: 'SocketException: Failed host lookup',
            posts: const [],
            onRetry: () => retried = true,
            onCreate: () {},
            onOpenMenu: (_) {},
          ),
        ),
      );
      await tester.pump();

      expect(find.text(myPostsErrorTitle), findsOneWidget);
      expect(find.text('SocketException: Failed host lookup'), findsOneWidget);
      await tester.tap(find.text(myPostsErrorActionLabel));
      await tester.pump();
      expect(retried, isTrue);
      expect(find.byKey(const Key('my-posts-list')), findsNothing);
      expect(find.byKey(const Key('my-posts-item-menu')), findsNothing);
    });

    testWidgets('banner de falha na edição fica visível', (tester) async {
      await tester.pumpWidget(
        wrap(
          const CreatePostFeedbackBanner(
            message: 'Falha de rede ao salvar o post',
            success: false,
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Falha de rede ao salvar o post'), findsOneWidget);
    });

    testWidgets('create-post-submit desabilitado sem conteúdo', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        wrap(
          AppButton(
            key: const Key('create-post-submit'),
            label: 'Atualizar Post',
            disabled: !canPublishCreatePost(text: '', hasMedia: false),
            onPressed: () => pressed = true,
          ),
        ),
      );
      await tester.pump();

      final button = tester.widget<AppButton>(
        find.byKey(const Key('create-post-submit')),
      );
      expect(button.disabled, isTrue);
      await tester.tap(find.byKey(const Key('create-post-submit')));
      await tester.pump();
      expect(pressed, isFalse);
    });

    testWidgets('cancelar no sheet de opções não edita nem deleta', (
      tester,
    ) async {
      var edited = false;
      var deleted = false;
      var closed = false;
      await tester.pumpWidget(
        wrap(
          MyPostOptionsSheet(
            visible: true,
            onClose: () => closed = true,
            onEdit: () => edited = true,
            onDelete: () => deleted = true,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key('my-posts-menu-cancel')));
      await tester.pump();
      expect(closed, isTrue);
      expect(edited, isFalse);
      expect(deleted, isFalse);
    });

    testWidgets('fã não vê Live/Meet do artista no menu +', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [authSessionProvider.overrideWith(_FanAuth.new)],
          child: MaterialApp(
            theme: buildCrowdFansTheme(Brightness.light),
            home: const _CreateMenuHarness(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('nav-create')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('create-menu-live')), findsNothing);
      expect(find.byKey(const Key('create-menu-meet')), findsNothing);
      expect(find.byKey(const Key('create-menu-create-post')), findsNothing);
      expect(find.byKey(const Key('create-menu-my-posts')), findsOneWidget);
    });
  });

  group('CF-130 EDGE', () {
    test('canPublishCreatePost no limite 280 e só mídia', () {
      expect(canPublishCreatePost(text: 'E' * 280, hasMedia: false), isTrue);
      expect(canPublishCreatePost(text: '', hasMedia: true), isTrue);
    });

    testWidgets('row com texto longo não estoura (ellipsis)', (tester) async {
      final long = 'E' * 280;
      await tester.pumpWidget(
        wrap(
          MyPostRow(
            post: samplePost(text: long),
            onOpenMenu: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('my-posts-item-menu')), findsOneWidget);
      final text = tester.widget<Text>(find.text(long));
      expect(text.maxLines, 3);
      expect(text.overflow, TextOverflow.ellipsis);
    });

    test('formatMyPostDate: agora / vazio inválido', () {
      expect(formatMyPostDate('not-a-date'), '');
      expect(
        formatMyPostDate(DateTime.now().toIso8601String()),
        'agora',
      );
    });

    testWidgets('EDGE: lista vazia (zero posts) e CTA criar', (tester) async {
      var created = false;
      await tester.pumpWidget(
        wrap(
          MyPostsBody(
            loading: false,
            posts: const [],
            onRetry: () {},
            onCreate: () => created = true,
            onOpenMenu: (_) {},
          ),
        ),
      );
      await tester.pump();

      expect(find.text(myPostsEmptyTitle), findsOneWidget);
      expect(find.text(myPostsEmptyMessage), findsOneWidget);
      expect(find.byKey(const Key('my-posts-item-menu')), findsNothing);
      await tester.tap(find.text(myPostsEmptyActionLabel));
      await tester.pump();
      expect(created, isTrue);
    });

    testWidgets('EDGE: teclado maxLength 280 não aceita overflow', (
      tester,
    ) async {
      var value = '';
      await tester.pumpWidget(
        wrap(
          AppTextField(
            key: const Key('create-post-content'),
            label: 'Descrição',
            maxLines: 6,
            maxLength: createPostMaxLength,
            onChanged: (next) => value = next,
          ),
        ),
      );
      await tester.pump();

      await tester.enterText(find.byType(TextFormField), '${'E' * 300}');
      await tester.pump();
      expect(value.length, createPostMaxLength);
      expect(
        canPublishCreatePost(text: value, hasMedia: false),
        isTrue,
      );

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump();
      expect(find.byType(TextFormField), findsOneWidget);
    });

    test('createPostLengthLabel no zero e no limite', () {
      expect(createPostLengthLabel(0), '0/280');
      expect(createPostLengthLabel(createPostMaxLength), '280/280');
    });

    testWidgets('sheet oculto não mostra ações', (tester) async {
      await tester.pumpWidget(
        wrap(
          MyPostOptionsSheet(
            visible: false,
            onClose: () {},
            onEdit: () {},
            onDelete: () {},
          ),
        ),
      );
      await tester.pump();
      expect(find.byKey(const Key('my-posts-edit')), findsNothing);
      expect(find.byKey(const Key('my-posts-delete')), findsNothing);
    });
  });
}

/// Espelho do MainShell: sheet + toggle no (+).
class _CreateMenuHarness extends StatefulWidget {
  const _CreateMenuHarness();

  @override
  State<_CreateMenuHarness> createState() => _CreateMenuHarnessState();
}

class _CreateMenuHarnessState extends State<_CreateMenuHarness> {
  var _open = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Scaffold(body: SizedBox.expand()),
        CreateMenuSheet(
          visible: _open,
          onClose: () => setState(() => _open = false),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Material(
            color: Colors.white,
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 68,
                child: Center(
                  child: IconButton(
                    key: const Key('nav-create'),
                    onPressed: () => setState(() => _open = !_open),
                    icon: const Icon(Icons.add),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ArtistAuth extends AuthSessionNotifier {
  @override
  AuthSession build() {
    return const AuthSession(
      isLoading: false,
      isBackendValidated: true,
      profile: Profile(
        userUid: 'artist-1',
        displayName: 'Artista',
        name: 'Artista',
        description: '',
        photoUrl: '',
        isArtist: true,
      ),
    );
  }
}

class _FanAuth extends AuthSessionNotifier {
  @override
  AuthSession build() {
    return const AuthSession(
      isLoading: false,
      isBackendValidated: true,
      profile: Profile(
        userUid: 'fan-1',
        displayName: 'Fan',
        name: 'Fan',
        description: '',
        photoUrl: '',
        isArtist: false,
      ),
    );
  }
}
