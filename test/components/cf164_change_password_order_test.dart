import 'package:crowdfans/components/input/app_text_field.dart';
import 'package:crowdfans/components/profile/password_requirements_card.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/screens/profile/profile_security_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CF-164: campos em sequência e critérios abaixo', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: const ProfileSecurityScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Alterar senha'), findsWidgets);
    expect(find.text('Senha atual'), findsWidgets);
    expect(find.text('Nova senha'), findsWidgets);
    expect(find.text('Confirmar nova senha'), findsWidgets);
    expect(find.text('Critérios da nova senha'), findsOneWidget);

    final labels = tester
        .widgetList<AppTextField>(find.byType(AppTextField))
        .map((f) => f.label)
        .toList();
    expect(labels, [
      'Senha atual',
      'Nova senha',
      'Confirmar nova senha',
    ]);

    final fieldsY = tester
        .widgetList<AppTextField>(find.byType(AppTextField))
        .map((f) => tester.getTopLeft(find.byWidget(f)).dy)
        .toList();
    final criteriaY = tester.getTopLeft(find.byType(PasswordRequirementsCard)).dy;
    expect(fieldsY[0] < fieldsY[1], isTrue);
    expect(fieldsY[1] < fieldsY[2], isTrue);
    expect(fieldsY[2] < criteriaY, isTrue);
  });
}
