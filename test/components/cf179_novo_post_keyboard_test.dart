import 'package:crowdfans/components/fan_club/fan_club_compose_artist.dart';
import 'package:crowdfans/components/fan_club/fan_club_selector_field.dart';
import 'package:crowdfans/components/post/novo_post_composer_body.dart';
import 'package:crowdfans/components/post/novo_post_header.dart';
import 'package:crowdfans/components/post/novo_post_media_toolbar.dart';
import 'package:crowdfans/components/post/novo_post_media_toolbar_button.dart';
import 'package:crowdfans/components/post/post_avatar.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

/// Espelha o Column do [FanClubComposeScreen] (CF-179):
/// AnimatedPadding(viewInsets) → header + lista + toolbar.
class _Cf179ComposeHarness extends StatelessWidget {
  const _Cf179ComposeHarness({
    required this.controller,
    required this.focusNode,
    required this.remaining,
    this.canSubmit = false,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final int remaining;
  final bool canSubmit;

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final bottomPad = keyboardInset > 0 ? keyboardInset : safeBottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: false,
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(bottom: bottomPad),
          child: Column(
            children: [
              NovoPostHeader(
                subtitle: 'Fã Clube',
                canSubmit: canSubmit,
                publishing: false,
                onCancel: () {},
                onPublish: () {},
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    FanClubSelectorField(
                      selected: const FanClubComposeArtist(
                        id: 'mayra',
                        name: 'Mayra',
                        avatarUrl: '',
                      ),
                      expanded: false,
                      onPressed: () {},
                    ),
                    const SizedBox(height: 24),
                    NovoPostComposerBody(
                      avatarUrl: '',
                      controller: controller,
                      focusNode: focusNode,
                      onChanged: (_) {},
                      onFocus: () {},
                    ),
                  ],
                ),
              ),
              NovoPostMediaToolbar(
                remainingCharacters: remaining,
                onPickGallery: () {},
                onTakePhoto: () {},
                onPickVideo: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _pumpHarness(
  WidgetTester tester, {
  EdgeInsets viewInsets = EdgeInsets.zero,
  EdgeInsets padding = EdgeInsets.zero,
  int remaining = 280,
  bool canSubmit = false,
  Size surface = const Size(390, 844),
}) async {
  final controller = TextEditingController();
  final focus = FocusNode();
  addTearDown(controller.dispose);
  addTearDown(focus.dispose);

  await tester.binding.setSurfaceSize(surface);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(
        size: surface,
        viewInsets: viewInsets,
        padding: padding,
      ),
      child: MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: _Cf179ComposeHarness(
          controller: controller,
          focusNode: focus,
          remaining: remaining,
          canSubmit: canSubmit,
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('CF-179 green — teclado / Postar / avatar', () {
    testWidgets('Column sobe com teclado; anexos e contador acessíveis', (
      tester,
    ) async {
      await _pumpHarness(
        tester,
        viewInsets: const EdgeInsets.only(bottom: 300),
        remaining: 240,
      );

      final padding = tester.widget<AnimatedPadding>(
        find.byType(AnimatedPadding),
      );
      expect((padding.padding as EdgeInsets).bottom, 300);
      expect(find.byKey(const Key('novo-post-gallery')), findsOneWidget);
      expect(find.byKey(const Key('novo-post-camera')), findsOneWidget);
      expect(find.byKey(const Key('novo-post-video')), findsOneWidget);
      expect(find.byKey(const Key('novo-post-char-counter')), findsOneWidget);
      expect(find.text('240'), findsOneWidget);
    });

    testWidgets(
      'com teclado: seletor, campo, anexos e contador permanecem na tela',
      (tester) async {
        await _pumpHarness(
          tester,
          viewInsets: const EdgeInsets.only(bottom: 280),
          remaining: 200,
        );

        expect(find.byKey(const Key('novo-post-club-selector')), findsOneWidget);
        expect(find.byKey(const Key('novo-post-content')), findsOneWidget);
        expect(find.byKey(const Key('novo-post-gallery')), findsOneWidget);
        expect(find.byKey(const Key('novo-post-camera')), findsOneWidget);
        expect(find.byKey(const Key('novo-post-video')), findsOneWidget);
        expect(find.byKey(const Key('novo-post-char-counter')), findsOneWidget);

        final toolbarY = tester.getTopLeft(find.byType(NovoPostMediaToolbar)).dy;
        final surfaceH = tester.getSize(find.byType(MaterialApp)).height;
        expect(toolbarY, lessThan(surfaceH - 280));
        expect(toolbarY, greaterThan(0));
      },
    );

    testWidgets('Postar desabilitado permanece legível', (tester) async {
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
      expect(text.style?.color, isNot(colors.buttonPrimaryText));
    });

    testWidgets('avatar sem URL usa fallback intencional', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: const Scaffold(body: PostAvatar(url: '', size: 52)),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('ícones de mídia usam roxo primary', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: NovoPostMediaToolbar(
              remainingCharacters: 100,
              onPickGallery: () {},
              onTakePhoto: () {},
              onPickVideo: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(NovoPostMediaToolbarButton), findsNWidgets(3));
      final svgs = tester.widgetList<SvgPicture>(find.byType(SvgPicture)).toList();
      expect(svgs.length, greaterThanOrEqualTo(3));
      for (final svg in svgs.take(3)) {
        final filter = svg.colorFilter;
        expect(filter, isNotNull);
        expect(filter.toString(), contains(AppColors.light.primary.toString()));
      }
    });
  });

  group('CF-179 red — bloqueios / anti-overlap', () {
    testWidgets('Postar desabilitado não dispara onPublish', (tester) async {
      var published = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: NovoPostHeader(
              subtitle: 'Fã Clube',
              canSubmit: false,
              publishing: false,
              onCancel: () {},
              onPublish: () => published = true,
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key('novo-post-submit')));
      await tester.pump();
      expect(published, isFalse);
    });

    testWidgets('sem conteúdo útil: canSubmit false no harness', (tester) async {
      await _pumpHarness(tester, canSubmit: false);
      final ink = tester.widget<InkWell>(find.byKey(const Key('novo-post-submit')));
      expect(ink.onTap, isNull);
    });

    testWidgets('sem chips CF-141 Texto/Imagem no composer', (tester) async {
      await _pumpHarness(tester);
      expect(find.text('Texto'), findsNothing);
      expect(find.text('Imagem'), findsNothing);
      expect(find.text('Tipo'), findsNothing);
    });

    testWidgets('sem banner CF-177 de modo secreto no harness base', (tester) async {
      await _pumpHarness(tester);
      expect(find.byKey(const Key('novo-post-secret-banner')), findsNothing);
      expect(find.text('Modo secreto ativo'), findsNothing);
    });

    testWidgets('contador negativo usa cor danger', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: NovoPostMediaToolbar(
              remainingCharacters: -5,
              onPickGallery: () {},
              onTakePhoto: () {},
              onPickVideo: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      final counter = tester.widget<Text>(
        find.byKey(const Key('novo-post-char-counter')),
      );
      expect(counter.data, '-5');
      expect(counter.style?.color, AppColors.light.danger);
    });
  });

  group('CF-179 edge — safe area / overflow / insets', () {
    testWidgets('sem teclado: padding usa safe bottom, não viewInsets', (
      tester,
    ) async {
      await _pumpHarness(
        tester,
        viewInsets: EdgeInsets.zero,
        padding: const EdgeInsets.only(bottom: 34),
      );

      final pad = tester.widget<AnimatedPadding>(find.byType(AnimatedPadding));
      expect((pad.padding as EdgeInsets).bottom, 34);
    });

    testWidgets('texto longo 280: contador zera sem overflow', (tester) async {
      await _pumpHarness(
        tester,
        remaining: 0,
        viewInsets: const EdgeInsets.only(bottom: 250),
      );

      expect(find.text('0'), findsOneWidget);
      final counter = tester.widget<Text>(
        find.byKey(const Key('novo-post-char-counter')),
      );
      expect(counter.style?.color, AppColors.light.textTertiary);
      expect(tester.takeException(), isNull);
    });

    testWidgets('hint do campo não compete com contador da toolbar', (
      tester,
    ) async {
      await _pumpHarness(tester);
      expect(find.text('O que quer postar hoje?'), findsOneWidget);
      expect(find.textContaining('/280'), findsNothing);
      expect(find.byKey(const Key('novo-post-char-counter')), findsOneWidget);
    });

    testWidgets('surface estreita + teclado: sem overflow do Column', (
      tester,
    ) async {
      await _pumpHarness(
        tester,
        surface: const Size(320, 640),
        viewInsets: const EdgeInsets.only(bottom: 220),
        remaining: 12,
      );

      expect(find.byKey(const Key('novo-post-club-selector')), findsOneWidget);
      expect(find.byKey(const Key('novo-post-char-counter')), findsOneWidget);
      expect(tester.takeException(), isNull);

      final pad = tester.widget<AnimatedPadding>(find.byType(AnimatedPadding));
      expect((pad.padding as EdgeInsets).bottom, 220);
      final toolbarH = tester.getSize(find.byType(NovoPostMediaToolbar)).height;
      // Toolbar chrome only — keyboard pad is on the parent AnimatedPadding.
      expect(toolbarH, lessThan(100));
    });
  });
}
