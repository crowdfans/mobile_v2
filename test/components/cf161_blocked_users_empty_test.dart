import 'package:crowdfans/components/profile/blocked_users_empty_state.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/components/profile/profile_state.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CF-161: título Usuários Bloqueados e vazio à esquerda', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: Column(
            children: [
              ProfileScreenHeader(title: 'Usuários Bloqueados', onBack: () {}),
              const Expanded(child: BlockedUsersEmptyState()),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Usuários Bloqueados'), findsOneWidget);
    expect(find.text('Nenhum usuário bloqueado'), findsOneWidget);
    expect(
      find.text(
        'Quando você bloquear alguém, o perfil aparecerá aqui para desbloqueio.',
      ),
      findsOneWidget,
    );
    expect(find.text('Bloqueados'), findsNothing);
    expect(find.text('Ninguém bloqueado'), findsNothing);

    final state = tester.widget<ProfileState>(find.byType(ProfileState));
    expect(state.align, TextAlign.left);
  });
}
