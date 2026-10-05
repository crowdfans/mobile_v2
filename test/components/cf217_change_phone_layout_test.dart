import 'package:crowdfans/components/input/app_text_field.dart';
import 'package:crowdfans/components/profile/settings_segmented_tabs.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/screens/profile/profile_change_phone_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CF-217: Trocar telefone espelha referência (sem abas/olho)', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: const ProfileChangePhoneScreen(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Trocar telefone'), findsOneWidget);
    expect(find.text('Segurança e login'), findsNothing);
    expect(find.text('Segurança e Login'), findsNothing);
    expect(find.text('Atualize o telefone de recuperação'), findsOneWidget);
    expect(
      find.text(
        'Usaremos esse número para OTPs, confirmação de login e '
        'recuperação de acesso quando necessário.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('Telefone atual:'), findsOneWidget);
    expect(find.byType(SettingsSegmentedTabs), findsNothing);
    expect(find.text('Alterar senha'), findsNothing);
    expect(find.text('Trocar e-mail'), findsNothing);
    expect(find.text('Telefone e dispositivos'), findsNothing);
    expect(find.text('Dispositivos conectados'), findsNothing);
    expect(find.text('Continuar'), findsOneWidget);

    final headline = tester.widget<Text>(
      find.text('Atualize o telefone de recuperação'),
    );
    expect(headline.style?.fontWeight, FontWeight.w800);
    expect(headline.style?.fontSize, 22);

    final fields = tester
        .widgetList<AppTextField>(find.byType(AppTextField))
        .toList();
    expect(fields.map((f) => f.label).toList(), [
      'Senha atual',
      'Novo telefone',
    ]);
    expect(fields.map((f) => f.hint).toList(), [
      'Digite sua senha atual',
      '(11) 99999-9999',
    ]);
    expect(fields[0].obscureText, isTrue);
    expect(fields[0].showObscureToggle, isFalse);
    expect(find.byIcon(Icons.visibility), findsNothing);
    expect(find.byIcon(Icons.visibility_off), findsNothing);
  });
}
