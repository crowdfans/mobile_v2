import 'package:crowdfans/components/profile/security_access_nav_row.dart';
import 'package:crowdfans/components/profile/security_protection_toggle_row.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/screens/profile/profile_change_email_screen.dart';
import 'package:crowdfans/screens/profile/profile_change_phone_screen.dart';
import 'package:crowdfans/screens/profile/profile_security_credentials_screen.dart';
import 'package:crowdfans/screens/profile/profile_security_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// CF-215 — hub Segurança e Login vs print (image1.png).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('CF-215 linhas de proteção e acesso', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: ListView(
            children: [
              SecurityProtectionToggleRow(
                title: 'Alertas de novo login',
                subtitle: 'Avisar.',
                value: true,
                onChanged: (_) {},
              ),
              SecurityAccessNavRow(
                title: 'Dispositivos conectados',
                subtitle: 'Revise.',
                onTap: () {},
                showDivider: false,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Alertas de novo login'), findsOneWidget);
    expect(find.text('Dispositivos conectados'), findsOneWidget);
    final onSwitch = tester.widget<Switch>(find.byType(Switch));
    expect(onSwitch.value, isTrue);
    expect(onSwitch.activeTrackColor, AppPalette.purple500);
  });

  testWidgets('CF-215 layout hub vs print', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: const ProfileSecurityScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Segurança e Login'), findsOneWidget);
    expect(find.text('Proteção da Conta'), findsOneWidget);
    expect(find.text('Autenticação em dois fatores'), findsOneWidget);
    expect(
      find.text('Exigir código adicional ao entrar na conta.'),
      findsOneWidget,
    );
    expect(find.text('Alertas de novo login'), findsOneWidget);
    expect(
      find.text('Avisar quando detectarmos acesso em novo dispositivo.'),
      findsOneWidget,
    );
    expect(find.text('Acesso'), findsOneWidget);
    expect(find.text('Alterar senha'), findsOneWidget);
    expect(find.text('Atualize sua senha periodicamente.'), findsOneWidget);
    expect(find.text('Trocar e-mail'), findsOneWidget);
    expect(
      find.text('Atualize o e-mail principal usado no login.'),
      findsOneWidget,
    );
    expect(find.text('Trocar telefone'), findsOneWidget);
    expect(
      find.text('Atualize o número usado em verificações de segurança.'),
      findsOneWidget,
    );
    expect(find.text('Dispositivos conectados'), findsOneWidget);
    expect(find.text('Revise onde sua conta está logada.'), findsOneWidget);

    // Sem abas A009/A014 / telefone-e-dispositivos embutido.
    expect(find.text('Segurança e login'), findsNothing);
    expect(find.text('Telefone e dispositivos'), findsNothing);
    expect(find.text('Alterar Senha'), findsNothing);

    final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
    expect(switches, hasLength(2));
    // 2FA incompleto → OFF; alertas default → ON (print).
    expect(switches[0].value, isFalse);
    expect(switches[1].value, isTrue);

    // Ordem visual: Proteção → 2FA → alertas → Acesso → 4 destinos.
    final titles = [
      'Proteção da Conta',
      'Autenticação em dois fatores',
      'Alertas de novo login',
      'Acesso',
      'Alterar senha',
      'Trocar e-mail',
      'Trocar telefone',
      'Dispositivos conectados',
    ];
    double? lastY;
    for (final title in titles) {
      final y = tester.getTopLeft(find.text(title)).dy;
      if (lastY != null) {
        expect(y, greaterThan(lastY), reason: '$title deve vir depois');
      }
      lastY = y;
    }
  });

  testWidgets('CF-215 2FA não fica ligado sem fluxo completo', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: const ProfileSecurityScreen(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
    expect(switches[0].value, isFalse);
    expect(
      find.text(
        'A autenticação em dois fatores ainda não está disponível neste app.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('CF-215 hub → quatro destinos reais', (tester) async {
    final router = GoRouter(
      initialLocation: Pages.profileSecurity,
      routes: [
        GoRoute(
          path: Pages.profileSecurity,
          builder: (context, state) => const ProfileSecurityScreen(),
        ),
        GoRoute(
          path: Pages.profileChangePassword,
          builder: (context, state) => const ProfileSecurityCredentialsScreen(),
        ),
        GoRoute(
          path: Pages.profileChangeEmail,
          builder: (context, state) => const ProfileChangeEmailScreen(),
        ),
        GoRoute(
          path: Pages.profileChangePhone,
          builder: (context, state) => const ProfileChangePhoneScreen(),
        ),
        GoRoute(
          path: Pages.profileConnectedDevices,
          builder: (context, state) =>
              const Scaffold(body: Text('Dispositivos stub')),
        ),
      ],
    );

    Future<void> openHub() async {
      router.go(Pages.profileSecurity);
      await tester.pumpWidget(
        MaterialApp.router(
          theme: buildCrowdFansTheme(Brightness.light),
          routerConfig: router,
        ),
      );
      await tester.pumpAndSettle();
    }

    await openHub();
    await tester.tap(find.text('Alterar senha'));
    await tester.pumpAndSettle();
    expect(router.state.uri.path, Pages.profileChangePassword);

    await openHub();
    await tester.tap(find.text('Trocar e-mail'));
    await tester.pumpAndSettle();
    expect(router.state.uri.path, Pages.profileChangeEmail);

    await openHub();
    await tester.tap(find.text('Trocar telefone'));
    await tester.pumpAndSettle();
    expect(router.state.uri.path, Pages.profileChangePhone);

    await openHub();
    await tester.tap(find.text('Dispositivos conectados'));
    await tester.pumpAndSettle();
    expect(router.state.uri.path, Pages.profileConnectedDevices);
  });
}
