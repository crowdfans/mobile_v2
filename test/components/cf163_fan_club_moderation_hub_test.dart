import 'package:crowdfans/components/profile/moderation_hub_card.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/screens/profile/moderation_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

/// CF-163 — hub Fã Clube vs print (image.png LEFT).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrap(GoRouter router) {
    return MaterialApp.router(
      theme: buildCrowdFansTheme(Brightness.light),
      routerConfig: router,
    );
  }

  testWidgets('CF-163: hub Fã Clube sem contornos e com textos aprovados', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: Pages.profileModeration,
      routes: [
        GoRoute(
          path: Pages.profileModeration,
          builder: (context, state) => const ModerationSettingsScreen(),
        ),
        GoRoute(
          path: Pages.profileModerationList,
          builder: (context, state) =>
              const Scaffold(body: Text('lista-moderacao')),
        ),
        GoRoute(
          path: Pages.profileContestations,
          builder: (context, state) =>
              const Scaffold(body: Text('lista-contestacoes')),
        ),
      ],
    );

    await tester.pumpWidget(wrap(router));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Fã Clube'), findsOneWidget);
    expect(find.text('Moderação do Fã Clube'), findsNothing);
    expect(find.text('Moderação'), findsOneWidget);
    expect(
      find.text('Veja os fã clubes em que você é moderador.'),
      findsOneWidget,
    );
    expect(find.text('Suas Contestações'), findsOneWidget);
    expect(find.text('Suas contestações'), findsNothing);
    expect(
      find.text(
        'Acompanhe seus pedidos de retorno e banimentos recebidos.',
      ),
      findsOneWidget,
    );

    // Print: badges circulares nas rows (não chevron-right).
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is SvgPicture &&
            w.bytesLoader.toString().contains('chevron-right'),
      ),
      findsNothing,
    );
    expect(find.text('0'), findsNWidgets(2));

    // Sem borda nos cards — tipografia w700 / textSecondary.
    final title = tester.widget<Text>(find.text('Moderação'));
    expect(title.style?.fontWeight, FontWeight.w700);
    final subtitle = tester.widget<Text>(
      find.text('Veja os fã clubes em que você é moderador.'),
    );
    final theme = CrowdFansTheme.of(
      tester.element(find.byType(ModerationSettingsScreen)),
    );
    expect(subtitle.style?.color, theme.textSecondary);

    // Sem Border nos containers dos badges / rows.
    final containers = tester.widgetList<Container>(find.byType(Container));
    for (final c in containers) {
      final decoration = c.decoration;
      if (decoration is BoxDecoration) {
        expect(decoration.border, isNull);
      }
    }
  });

  testWidgets('CF-163: badge circular com contagem real', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: ModerationHubCard(
            title: 'Moderação',
            subtitle: 'Veja os fã clubes em que você é moderador.',
            badgeCount: 2,
            onTap: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('2'), findsOneWidget);
    expect(find.byType(SvgPicture), findsNothing);
  });

  testWidgets('CF-163: toques navegam para listas', (tester) async {
    final router = GoRouter(
      initialLocation: Pages.profileModeration,
      routes: [
        GoRoute(
          path: Pages.profileModeration,
          builder: (context, state) => const ModerationSettingsScreen(),
        ),
        GoRoute(
          path: Pages.profileModerationList,
          builder: (context, state) =>
              const Scaffold(body: Text('lista-moderacao')),
        ),
        GoRoute(
          path: Pages.profileContestations,
          builder: (context, state) =>
              const Scaffold(body: Text('lista-contestacoes')),
        ),
      ],
    );

    await tester.pumpWidget(wrap(router));
    await tester.pump();

    await tester.tap(find.text('Moderação'));
    await tester.pumpAndSettle();
    expect(find.text('lista-moderacao'), findsOneWidget);

    router.go(Pages.profileModeration);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Suas Contestações'));
    await tester.pumpAndSettle();
    expect(find.text('lista-contestacoes'), findsOneWidget);
  });
}
