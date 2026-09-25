import 'package:crowdfans/components/input/app_text_field.dart';
import 'package:crowdfans/components/profile/settings_segmented_tabs.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/screens/profile/profile_change_email_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CF-165: Trocar e-mail espelha referência (sem abas/técnico)', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: const ProfileChangeEmailScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Trocar e-mail'), findsOneWidget);
    expect(find.text('Atualize o e-mail da sua conta'), findsOneWidget);
    expect(
      find.text(
        'Para trocar o e-mail, a conta exige dois fatores: sua senha atual e '
        'um OTP enviado por SMS para o telefone protegido.',
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
    expect(find.text('Enviar confirmação'), findsOneWidget);

    final fields = tester
        .widgetList<AppTextField>(find.byType(AppTextField))
        .toList();
    expect(fields.map((f) => f.label).toList(), [
      'Senha atual',
      'Novo e-mail',
      'Confirmar novo e-mail',
    ]);
    expect(fields.map((f) => f.hint).toList(), [
      'Digite sua senha atual',
      'novo@email.com',
      'Repita o novo e-mail',
    ]);
    expect(fields[0].obscureText, isTrue);
  });
}
