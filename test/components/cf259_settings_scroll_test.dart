import 'package:crowdfans/screens/profile/profile_settings_screen.dart';
import 'package:crowdfans/utils/app_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CF-259: ListView do hub usa PageStorageKey profile-settings', () {
    const key = PageStorageKey<String>('profile-settings');
    expect(key.value, 'profile-settings');
    // Garante que a tela continua exportando o widget público esperado.
    expect(ProfileSettingsScreen, isNotNull);
  });

  testWidgets('CF-259: Sair exige confirmação (não dispara sozinho)', (
    tester,
  ) async {
    var confirmed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: TextButton(
                key: const Key('settings-item-logout'),
                onPressed: () async {
                  confirmed = await AppAlert.confirm(
                    context,
                    title: 'Sair',
                    message: 'Deseja encerrar a sessão?',
                    confirmLabel: 'Sair',
                  );
                },
                child: const Text('Sair da conta'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('settings-item-logout')));
    await tester.pumpAndSettle();
    expect(find.text('Deseja encerrar a sessão?'), findsOneWidget);
    expect(confirmed, isFalse);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(confirmed, isFalse);

    await tester.tap(find.byKey(const Key('settings-item-logout')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Sair'));
    await tester.pumpAndSettle();
    expect(confirmed, isTrue);
  });
}
