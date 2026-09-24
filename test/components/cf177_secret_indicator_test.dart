import 'package:crowdfans/components/post/novo_post_secret_banner.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CF-177: indicador secreto compacto sem faixa full-width', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: const Scaffold(
          body: SizedBox(
            width: 400,
            child: NovoPostSecretBanner(),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Modo secreto ativo'), findsOneWidget);
    final row = find.descendant(
      of: find.byType(NovoPostSecretBanner),
      matching: find.byType(Row),
    );
    expect(tester.getSize(row).width, lessThan(280));
    expect(find.byType(DecoratedBox), findsOneWidget); // só o ícone, sem faixa
  });
}
