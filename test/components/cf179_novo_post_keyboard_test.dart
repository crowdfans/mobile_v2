import 'package:crowdfans/components/post/novo_post_header.dart';
import 'package:crowdfans/components/post/novo_post_media_toolbar.dart';
import 'package:crowdfans/components/post/post_avatar.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'CF-179: barra de mídia e contador sobem com o teclado',
    (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(viewInsets: EdgeInsets.only(bottom: 300)),
          child: MaterialApp(
            theme: buildCrowdFansTheme(Brightness.light),
            home: Scaffold(
              resizeToAvoidBottomInset: false,
              body: Align(
                alignment: Alignment.bottomCenter,
                child: NovoPostMediaToolbar(
                  remainingCharacters: 240,
                  onPickGallery: () {},
                  onTakePhoto: () {},
                  onPickVideo: () {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final padding = tester.widget<AnimatedPadding>(
        find.byType(AnimatedPadding),
      );
      expect(padding.padding.bottom, 300);
      expect(find.byKey(const Key('novo-post-gallery')), findsOneWidget);
      expect(find.byKey(const Key('novo-post-camera')), findsOneWidget);
      expect(find.byKey(const Key('novo-post-video')), findsOneWidget);
      expect(find.byKey(const Key('novo-post-char-counter')), findsOneWidget);
      expect(find.text('240'), findsOneWidget);
    },
  );

  testWidgets('CF-179: Postar desabilitado permanece legível', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: NovoPostHeader(
            subtitle: 'Fã Clube',
            canSubmit: false,
            publishing: false,
            onCancel: () {},
            onPublish: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Postar'), findsOneWidget);
    expect(find.byKey(const Key('novo-post-submit')), findsOneWidget);
    final colors = AppColors.light;
    final text = tester.widget<Text>(
      find.descendant(
        of: find.byKey(const Key('novo-post-submit')),
        matching: find.text('Postar'),
      ),
    );
    expect(text.style?.color, colors.textSecondary);
  });

  testWidgets('CF-179: avatar sem URL usa fallback intencional', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: const Scaffold(body: PostAvatar(url: '', size: 52)),
      ),
    );
    await tester.pump();

    expect(find.byIcon(Icons.person), findsOneWidget);
  });
}
