import 'package:crowdfans/components/profile/account_photo_actions.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CF-220 ações de foto com rótulos aprovados', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: AccountPhotoActions(
            hasLocalPhoto: false,
            onGallery: () {},
            onCamera: () {},
          ),
        ),
      ),
    );

    expect(find.text('Escolha entre galeria ou câmera.'), findsOneWidget);
    expect(find.text('Selecionar foto da galeria'), findsOneWidget);
    expect(find.text('Tirar foto'), findsOneWidget);
  });
}
