import 'package:crowdfans/components/profile/security_change_phone_card.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/profile.dart';
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

  // CF-217 demock: telefone atual vem da API/Firebase, não de Cf217ChangePhoneMock.
  test('CF-217/CF-271 telefone atual via Profile API', () {
    final profile = Profile.fromJson({
      'userUid': 'u1',
      'displayName': 'Fan',
      'name': 'fan',
      'description': '',
      'photoUrl': '',
      'isArtist': false,
      'phone': '+5511987654321',
      'phoneVerified': true,
    });
    expect(profile.phone, '+5511987654321');
    expect(profile.phoneVerified, isTrue);
  });
}
