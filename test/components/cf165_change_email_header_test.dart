import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/screens/profile/profile_security_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CF-165: Trocar e-mail sem textos técnicos', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: const ProfileSecurityScreen(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Trocar e-mail').last);
    await tester.pumpAndSettle();

    expect(find.text('Trocar e-mail'), findsWidgets);
    expect(find.text('Atualize o e-mail da sua conta'), findsOneWidget);
    expect(find.textContaining('Firebase'), findsNothing);
    expect(find.textContaining('endpoints'), findsNothing);
    expect(find.textContaining('legado'), findsNothing);
    expect(find.text('Telefone e dispositivos'), findsNothing);
    expect(find.text('Senha atual'), findsOneWidget);
    expect(find.text('Novo e-mail'), findsOneWidget);
    expect(find.text('Confirmar novo e-mail'), findsOneWidget);
  });
}
