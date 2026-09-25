import 'package:crowdfans/components/profile/moderation_hub_card.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/screens/profile/moderation_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('CF-163: hub Fã Clube sem contornos e com textos aprovados', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/me/settings/moderation',
      routes: [
        GoRoute(
          path: '/me/settings/moderation',
          builder: (context, state) => const ModerationSettingsScreen(),
        ),
        GoRoute(
          path: '/me/settings/moderation-list',
          builder: (context, state) => const SizedBox.shrink(),
        ),
        GoRoute(
          path: '/me/settings/contestations',
          builder: (context, state) => const SizedBox.shrink(),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        theme: buildCrowdFansTheme(Brightness.light),
        routerConfig: router,
      ),
    );
    await tester.pump();

    expect(find.text('Fã Clube'), findsOneWidget);
    expect(find.text('Moderação do Fã Clube'), findsNothing);
    expect(find.text('Moderação'), findsOneWidget);
    expect(
      find.text('Veja os fã clubes em que você é moderador.'),
      findsOneWidget,
    );
    expect(find.text('Suas Contestações'), findsOneWidget);
    expect(
      find.text(
        'Acompanhe seus pedidos de retorno e banimentos recebidos.',
      ),
      findsOneWidget,
    );

    // Sem DecoratedBox com borda nos cards (InkWell + Padding apenas).
    expect(find.byType(DecoratedBox), findsNothing);
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
}
