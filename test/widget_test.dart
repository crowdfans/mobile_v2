import 'package:crowdfans/screens/onboarding/presentation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('abre o onboarding Superfã', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PresentationScreen()));
    await tester.pump();
    expect(find.text('CROWD FANS'), findsOneWidget);
    expect(find.textContaining('Superfã'), findsOneWidget);
  });
}
