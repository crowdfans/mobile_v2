import 'package:crowdfans/components/input/app_text_field.dart';
import 'package:crowdfans/components/profile/settings_segmented_tabs.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/screens/profile/profile_security_credentials_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CF-165: Trocar e-mail espelha referência (sem abas/técnico)', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: const ProfileSecurityCredentialsScreen(initialMode: 'email'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Trocar e-mail'), findsOneWidget);
    expect(find.text('Atualize o e-mail da sua conta'), findsOneWidget);
    expect(
      find.textContaining(
        'OTP enviado por SMS para o telefone protegido',
      ),
      findsOneWidget,
    );
    expect(find.byType(SettingsSegmentedTabs), findsNothing);
    expect(find.text('Alterar senha'), findsNothing);
    expect(find.textContaining('Firebase'), findsNothing);
    expect(find.textContaining('endpoints'), findsNothing);
    expect(find.textContaining('legado'), findsNothing);
    expect(find.text('Telefone e dispositivos'), findsNothing);
    expect(find.text('E-mail atual:'), findsNothing);

    final labels = tester
        .widgetList<AppTextField>(find.byType(AppTextField))
        .map((f) => f.label)
        .toList();
    expect(labels, [
      'Senha atual',
      'Novo e-mail',
      'Confirmar novo e-mail',
    ]);
  });
}
