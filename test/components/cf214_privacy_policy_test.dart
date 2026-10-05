import 'package:crowdfans/components/profile/information_document_view.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/screens/profile/profile_information_screen.dart';
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

    expect(find.byType(SelectionArea), findsOneWidget);
    expect(find.text('Política de privacidade detalhada'), findsOneWidget);
    expect(find.textContaining('Escopo desta política'), findsOneWidget);
    expect(
      find.textContaining('Categorias de dados que podem ser tratados'),
      findsOneWidget,
    );
    expect(find.textContaining('Finalidades do tratamento'), findsOneWidget);
    expect(
      find.textContaining('Compartilhamento, retenção e direitos'),
      findsOneWidget,
    );
    expect(find.textContaining('Jam Coins'), findsAtLeastNWidgets(1));
    expect(
      find.text('Última atualização: 17 de março de 2026.'),
      findsOneWidget,
    );
  });

  testWidgets('CF-214 rota privacy: sem abas, header e hierarquia do print', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: const ProfileInformationScreen(initialTab: 'privacy'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Política de Privacidade'), findsOneWidget);
    expect(find.text('Termos'), findsNothing);
    expect(find.text('Privacidade'), findsNothing);
    expect(find.text('Política de privacidade detalhada'), findsOneWidget);
    expect(
      find.text('Última atualização: 17 de março de 2026.'),
      findsOneWidget,
    );
    expect(find.textContaining('Escopo desta política'), findsOneWidget);
    expect(find.byType(SelectionArea), findsOneWidget);
  });
}
