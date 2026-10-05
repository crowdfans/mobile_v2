import 'package:crowdfans/components/profile/connected_device_row.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/screens/profile/profile_connected_devices_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('CF-216 linha Este dispositivo sem Desconectar', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: ConnectedDeviceRow(
            session: const ConnectedDeviceSession(
              id: '1',
              name: 'iPhone 15 Pro',
              platformLine: 'iOS · Crowd Fans App',
              location: 'São Paulo, Brasil',
              activity: 'Ativo agora',
              isCurrent: true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Este dispositivo'), findsOneWidget);
    expect(find.text('Desconectar'), findsNothing);

    final badge = tester.widget<Container>(
      find
          .ancestor(
            of: find.text('Este dispositivo'),
            matching: find.byType(Container),
          )
          .first,
    );
    final decoration = badge.decoration! as BoxDecoration;
    expect(decoration.color, AppPalette.purple100);
    final style = tester.widget<Text>(find.text('Este dispositivo')).style!;
    expect(style.color, AppPalette.purple700);
  });

  testWidgets('CF-216 tela bate com print (3 sessões + tip + CTA)', (
    tester,
  ) async {
    expect(kUseCf216ConnectedDevicesMocks, isTrue);

    final router = GoRouter(
      initialLocation: '/devices',
      routes: [
        GoRoute(
          path: '/devices',
          builder: (context, state) => const ProfileConnectedDevicesScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        theme: buildCrowdFansTheme(Brightness.light),
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dispositivos conectados'), findsOneWidget);
    expect(find.text('Sessões ativas na sua conta'), findsOneWidget);
    expect(
      find.textContaining(
        'Revise os aparelhos em que sua conta está logada',
      ),
      findsOneWidget,
    );
    expect(find.text('3'), findsOneWidget);
    expect(find.text('dispositivos conectados'), findsOneWidget);
    expect(find.text('iPhone 15 Pro'), findsOneWidget);
    expect(find.text('Este dispositivo'), findsOneWidget);
    expect(find.text('iOS · Crowd Fans App'), findsOneWidget);
    expect(find.text('São Paulo, Brasil'), findsNWidgets(2));
    expect(find.text('Ativo agora'), findsOneWidget);
    expect(find.text('MacBook Air'), findsOneWidget);
    expect(find.text('Chrome · Web'), findsOneWidget);
    expect(find.text('Hoje às 14:12'), findsOneWidget);
    expect(find.text('Galaxy S24'), findsOneWidget);
    expect(find.text('Android · Crowd Fans App'), findsOneWidget);
    expect(find.text('Campinas, Brasil'), findsOneWidget);
    expect(find.text('Ontem às 22:41'), findsOneWidget);
    expect(find.text('Desconectar'), findsNWidgets(2));
    await tester.scrollUntilVisible(
      find.text('Dica de segurança'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Dica de segurança'), findsOneWidget);
    expect(
      find.textContaining('Se você trocou a senha recentemente'),
      findsOneWidget,
    );
    expect(find.text('Desconectar todos menos este'), findsOneWidget);
  });

  testWidgets('CF-216 CTA todos menos este preserva sessão atual', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/devices',
      routes: [
        GoRoute(
          path: '/devices',
          builder: (context, state) => const ProfileConnectedDevicesScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        theme: buildCrowdFansTheme(Brightness.light),
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Desconectar todos menos este'));
    await tester.pumpAndSettle();
    // Confirma no AppAlert.
    await tester.tap(find.text('Desconectar').last);
    await tester.pumpAndSettle();

    expect(find.text('iPhone 15 Pro'), findsOneWidget);
    expect(find.text('Este dispositivo'), findsOneWidget);
    expect(find.text('MacBook Air'), findsNothing);
    expect(find.text('Galaxy S24'), findsNothing);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('dispositivo conectado'), findsOneWidget);
  });
}
