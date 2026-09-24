import 'package:crowdfans/components/profile/information_document_view.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CF-214 política oficial com escopo e data', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: const Scaffold(
          body: SingleChildScrollView(
            child: InformationDocumentView(
              title: 'Política de privacidade detalhada',
              intro: 'Intro.',
              lastUpdated: 'Última atualização: 17 de março de 2026.',
              sections: informationPrivacySections,
            ),
          ),
        ),
      ),
    );

    expect(find.textContaining('Escopo desta política'), findsOneWidget);
    expect(find.textContaining('Jam Coins'), findsOneWidget);
    expect(
      find.text('Última atualização: 17 de março de 2026.'),
      findsOneWidget,
    );
  });
}
