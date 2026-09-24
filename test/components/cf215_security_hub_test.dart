import 'package:crowdfans/components/profile/security_access_nav_row.dart';
import 'package:crowdfans/components/profile/security_protection_toggle_row.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
  });
}
