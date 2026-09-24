import 'package:crowdfans/components/profile/connected_device_row.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
  });
}
