import 'package:crowdfans/components/fan_club/fan_club_rules_section.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/screens/fan_clubs/fan_club_rules_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CF-226 regras oficiais com autoria e seções numeradas', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: const FanClubRulesScreen(),
      ),
    );

    expect(find.text('Diretrizes da Comunidade'), findsOneWidget);
    expect(
      find.text('Equipe Crowd Fans. Feito de fã pra fã. <3'),
      findsOneWidget,
    );
    expect(
      find.textContaining('1. Respeito sempre'),
      findsOneWidget,
    );
    expect(fanClubRulesSections.length, greaterThanOrEqualTo(7));
  });
}
