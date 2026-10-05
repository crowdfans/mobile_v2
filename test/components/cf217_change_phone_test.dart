import 'package:crowdfans/components/profile/security_change_phone_card.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CF-217 card Trocar telefone (atalho legado)', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: SecurityChangePhoneCard(onPressed: () => tapped = true),
        ),
      ),
    );

    expect(find.text('Trocar telefone'), findsOneWidget);
    await tester.tap(find.text('Trocar telefone'));
    expect(tapped, isTrue);
  });

  test('CF-217 fixture telefone do print', () {
    expect(Cf217ChangePhoneMock.currentPhoneLabel, '(11) 98765-4321');
  });
}
