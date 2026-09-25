import 'package:crowdfans/components/input/app_text_field.dart';
import 'package:crowdfans/components/profile/password_requirements_card.dart';
import 'package:crowdfans/components/profile/settings_segmented_tabs.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/screens/profile/profile_security_credentials_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CF-164: Alterar senha espelha referência (sem abas)', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: const ProfileSecurityCredentialsScreen(initialMode: 'password'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Alterar senha'), findsOneWidget);
    expect(find.text('Atualize sua senha de acesso'), findsOneWidget);
    expect(
      find.text(
        'Use uma combinação forte para proteger sua conta e evitar acessos indevidos.',
      ),
      findsOneWidget,
    );
    expect(find.byType(SettingsSegmentedTabs), findsNothing);
    expect(find.text('Trocar e-mail'), findsNothing);
    expect(find.text('Telefone e dispositivos'), findsNothing);
    expect(find.text('Salvar nova senha'), findsOneWidget);
    expect(find.text('Critérios da nova senha'), findsOneWidget);
    expect(find.textContaining('Pelo menos 8 caracteres'), findsOneWidget);
    expect(find.textContaining('Pelo menos 1 letra maiúscula'), findsOneWidget);
    expect(find.textContaining('Pelo menos 1 número'), findsOneWidget);
    expect(
      find.textContaining('Confirmação igual à nova senha'),
      findsOneWidget,
    );
    expect(find.textContaining('minúscula'), findsNothing);
    expect(find.textContaining('símbolo'), findsNothing);
    expect(find.text('Fraca'), findsNothing);

    final labels = tester
        .widgetList<AppTextField>(find.byType(AppTextField))
        .map((f) => f.label)
        .toList();
    expect(labels, [
      'Senha atual',
      'Nova senha',
      'Confirmar nova senha',
    ]);

    final hints = tester
        .widgetList<AppTextField>(find.byType(AppTextField))
        .map((f) => f.hint)
        .toList();
    expect(hints, [
      'Digite sua senha atual',
      'Digite sua nova senha',
      'Repita a nova senha',
    ]);

    final fieldsY = tester
        .widgetList<AppTextField>(find.byType(AppTextField))
        .map((f) => tester.getTopLeft(find.byWidget(f)).dy)
        .toList();
    final criteriaY =
        tester.getTopLeft(find.byType(PasswordRequirementsCard)).dy;
    expect(fieldsY[0] < fieldsY[1], isTrue);
    expect(fieldsY[1] < fieldsY[2], isTrue);
    expect(fieldsY[2] < criteriaY, isTrue);
  });
}
