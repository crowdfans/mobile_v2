import 'package:crowdfans/components/profile/account_avatar.dart';
import 'package:crowdfans/components/profile/account_photo_action_button.dart';
import 'package:crowdfans/components/profile/account_photo_actions.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CF-220 idle: helper + galeria/câmera aprovados, sem Salvar', (
    tester,
  ) async {
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
    expect(find.text('Salvar foto'), findsNothing);
    expect(
      find.text(
        'A imagem só substitui a atual depois que você salvar o upload.',
      ),
      findsNothing,
    );
    expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    expect(find.byIcon(Icons.photo_camera_outlined), findsOneWidget);
  });

  testWidgets('CF-220 pending: aviso de upload só após pick local', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: AccountPhotoActions(
            hasLocalPhoto: true,
            onGallery: () {},
            onCamera: () {},
          ),
        ),
      ),
    );

    expect(
      find.text(
        'A imagem só substitui a atual depois que você salvar o upload.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('CF-220 avatar preview grande (radius print)', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: const Scaffold(
          body: Center(child: AccountAvatar()),
        ),
      ),
    );

    final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
    expect(avatar.radius, AccountAvatar.radius);
    expect(AccountAvatar.radius, 64);
  });

  testWidgets('CF-220 botões outline stadium com ícone à direita', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: AccountPhotoActionButton(
            label: 'Selecionar foto da galeria',
            icon: Icons.image_outlined,
            onPressed: () {},
          ),
        ),
      ),
    );

    final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
    final shape = button.style?.shape?.resolve({});
    expect(shape, isA<StadiumBorder>());

    final sized = tester.widget<SizedBox>(
      find.ancestor(
        of: find.byType(OutlinedButton),
        matching: find.byType(SizedBox),
      ).first,
    );
    expect(sized.height, 56);

    final row = tester.widget<Row>(find.byType(Row));
    expect(row.children.last, isA<Icon>());
  });
}
