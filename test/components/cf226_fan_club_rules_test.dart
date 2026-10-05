import 'package:crowdfans/components/fan_club/fan_club_rules_section.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/screens/fan_clubs/fan_club_rules_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CF-226 regras oficiais com autoria e seções numeradas', (
    tester,
  ) async {
    // Viewport alto para o ListView construir todas as 7 seções.
    tester.view.physicalSize = const Size(400, 5000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: const FanClubRulesScreen(),
      ),
    );

    expect(find.text('Regras do Fã Clube'), findsOneWidget);
    expect(find.text('Diretrizes da Comunidade'), findsOneWidget);
    expect(find.byType(SelectionArea), findsOneWidget);

    // Print: autoria em duas linhas (não uma frase única).
    expect(find.text('Equipe Crowd Fans'), findsOneWidget);
    expect(find.text('Feito de fã pra fã. <3'), findsOneWidget);
    expect(
      find.text('Equipe Crowd Fans. Feito de fã pra fã. <3'),
      findsNothing,
    );

    expect(
      find.textContaining('1. Respeito sempre'),
      findsOneWidget,
    );
    expect(
      find.textContaining('2. Cada espaço tem sua vibe'),
      findsOneWidget,
    );
    expect(
      find.textContaining('7. Mantenha a energia boa'),
      findsOneWidget,
    );
    expect(fanClubRulesSections.length, 7);

    // Intro oficial do print.
    expect(
      find.textContaining('a música aproxima pessoas'),
      findsOneWidget,
    );
  });

  testWidgets('CF-226 cabeçalhos semânticos nas seções', (tester) async {
    tester.view.physicalSize = const Size(400, 5000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: const FanClubRulesScreen(),
      ),
    );

    final headers = find.byWidgetPredicate(
      (widget) => widget is Semantics && widget.properties.header == true,
    );
    // Headline + 7 seções numeradas.
    expect(headers, findsNWidgets(8));
  });
}
