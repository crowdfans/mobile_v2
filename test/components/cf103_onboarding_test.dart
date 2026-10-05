import 'package:crowdfans/components/onboarding/onboarding_buttons.dart';
import 'package:crowdfans/components/onboarding/presentation_slide.dart';
import 'package:crowdfans/components/story/story_background.dart';
import 'package:crowdfans/components/story/story_background_progress.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/story_background_videos.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/screens/onboarding/presentation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// CF-103 — onboarding Superfã/Artista (stories + CTAs) vs contrato Expo/ticket.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrapRouter({required String initial}) {
    return MaterialApp.router(
      theme: buildCrowdFansTheme(Brightness.light),
      routerConfig: GoRouter(
        initialLocation: initial,
        routes: [
          GoRoute(
            path: Pages.presentation,
            builder: (context, state) => const PresentationScreen(),
          ),
          GoRoute(
            path: Pages.loginFan,
            builder: (context, state) => const Scaffold(
              body: Text('FAN_LOGIN'),
            ),
          ),
          GoRoute(
            path: Pages.loginArtist,
            builder: (context, state) => const Scaffold(
              body: Text('ARTIST_LOGIN'),
            ),
          ),
        ],
      ),
    );
  }

  group('CF-103 green', () {
    testWidgets('copy do slide 0 + marca + CTAs Superfã/Artista', (
      tester,
    ) async {
      await tester.pumpWidget(wrapRouter(initial: Pages.presentation));
      await tester.pump();

      expect(find.text('CROWD FANS'), findsOneWidget);
      expect(find.text(presentationSlides[0].title), findsOneWidget);
      expect(find.text(presentationSlides[0].accent), findsOneWidget);
      expect(find.text(presentationSlides[0].subtitle), findsOneWidget);
      expect(find.textContaining('Superfã'), findsOneWidget);
      expect(find.textContaining('Artista'), findsOneWidget);
      expect(find.byKey(const Key('onboarding-superfan')), findsOneWidget);
      expect(find.byKey(const Key('onboarding-artist')), findsOneWidget);
      expect(find.byType(OnboardingButtons), findsOneWidget);
      expect(find.byType(StoryBackgroundProgress), findsOneWidget);
      expect(storyBackgroundVideos.length, presentationSlides.length);
      expect(storyBackgroundVideos, hasLength(3));
    });

    testWidgets('CTA Superfã navega para login fã', (tester) async {
      await tester.pumpWidget(wrapRouter(initial: Pages.presentation));
      await tester.pump();

      await tester.tap(find.byKey(const Key('onboarding-superfan')));
      await tester.pumpAndSettle();

      expect(find.text('FAN_LOGIN'), findsOneWidget);
      expect(find.text('ARTIST_LOGIN'), findsNothing);
    });

    testWidgets('CTA Artista navega para login artista', (tester) async {
      await tester.pumpWidget(wrapRouter(initial: Pages.presentation));
      await tester.pump();

      await tester.tap(find.byKey(const Key('onboarding-artist')));
      await tester.pumpAndSettle();

      expect(find.text('ARTIST_LOGIN'), findsOneWidget);
      expect(find.text('FAN_LOGIN'), findsNothing);
    });

    testWidgets('tap direita avança o slide; esquerda volta', (tester) async {
      var index = -1;
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: StoryBackground(onVideoChange: (i) => index = i),
          ),
        ),
      );
      await tester.pump();
      // Aguarda init + possível fallback arm.
      await tester.pump(const Duration(milliseconds: 50));
      expect(index, 0);
      expect(find.byKey(const Key('onboarding-story-next')), findsOneWidget);
      expect(find.byKey(const Key('onboarding-story-prev')), findsOneWidget);

      await tester.tap(find.byKey(const Key('onboarding-story-next')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(index, 1);

      await tester.tap(find.byKey(const Key('onboarding-story-prev')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(index, 0);
    });
  });

  group('CF-103 red', () {
    testWidgets('sem CTA Superfã não há caminho fantasma para login fã', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: const Scaffold(
            body: PresentationSlide(
              data: PresentationSlideData(
                title: 'Só slide',
                accent: 'Sem botões',
                subtitle: 'Não deve haver CTAs.',
              ),
              textColor: AppPalette.platinum50,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('onboarding-superfan')), findsNothing);
      expect(find.byKey(const Key('onboarding-artist')), findsNothing);
      expect(find.textContaining('Sou um'), findsNothing);
    });

    testWidgets('labels erradas não batem o contrato do mock', (tester) async {
      await tester.pumpWidget(wrapRouter(initial: Pages.presentation));
      await tester.pump();

      expect(find.text('Sou um fã'), findsNothing);
      expect(find.text('Sou artista'), findsNothing);
      expect(find.text('Get started'), findsNothing);
      expect(find.text('Continue'), findsNothing);
    });
  });

  group('CF-103 edge', () {
    testWidgets('progresso no slide 2 usa contraste escuro', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                StoryBackgroundProgress(
                  currentIndex: 1,
                  isSecondStory: true,
                  progress: 0.4,
                  top: 12,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      final bars = tester.widgetList<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(bars, hasLength(3));
      expect(bars.elementAt(0).value, 1);
      expect(bars.elementAt(1).value, closeTo(0.4, 0.001));
      expect(bars.elementAt(2).value, 0);
      expect(bars.first.color, AppPalette.platinum950);
      expect(bars.first.backgroundColor, const Color(0x330A0A0A));
    });

    testWidgets('progresso no slide 0 usa contraste claro', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                StoryBackgroundProgress(
                  currentIndex: 0,
                  isSecondStory: false,
                  progress: 0,
                  top: 12,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      final bar = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator).first,
      );
      expect(bar.color, AppPalette.platinum50);
      expect(bar.backgroundColor, const Color(0x47FFFFFF));
    });

    testWidgets('subtítulo longo não estoura layout do slide', (tester) async {
      const long = PresentationSlideData(
        title: 'Título',
        accent: 'Acento',
        subtitle:
            'Texto bem longo para validar wrap no onboarding sem overflow '
            'horizontal quando o mock trouxer copy extensa do Drive.',
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              child: PresentationSlide(
                data: long,
                textColor: AppPalette.platinum50,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.textContaining('Texto bem longo'), findsOneWidget);
    });

    testWidgets('darkMode inverte cores dos CTAs no slide 2', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OnboardingButtons(
              darkMode: true,
              onSuperfan: () {},
              onArtist: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      final button = tester.widget<FilledButton>(
        find.descendant(
          of: find.byKey(const Key('onboarding-superfan')),
          matching: find.byType(FilledButton),
        ),
      );
      final style = button.style!;
      expect(
        style.backgroundColor!.resolve({}),
        AppPalette.platinum950,
      );
      expect(
        style.foregroundColor!.resolve({}),
        AppPalette.platinum50,
      );
    });
  });
}
