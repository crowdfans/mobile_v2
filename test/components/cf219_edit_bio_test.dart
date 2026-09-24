import 'package:crowdfans/components/profile/profile_bio_field_meta.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CF-219 meta da bio: auxiliar + contador', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: const Scaffold(
          body: ProfileBioFieldMeta(count: 56),
        ),
      ),
    );

    expect(find.text('Ela aparece no topo do seu perfil.'), findsOneWidget);
    expect(find.text('56'), findsOneWidget);
  });
}
