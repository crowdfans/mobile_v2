import 'package:crowdfans/components/notifications/notification_empty_state.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/notifications_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CF-190: vazio igual ao print (uma linha, sem título extra)', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: const Scaffold(
          body: NotificationEmptyState(tab: NotificationTab.all),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Nenhuma notificação nesta aba ainda.'), findsOneWidget);
    expect(find.textContaining('Sem novidades'), findsNothing);
    expect(find.textContaining('por aqui ainda'), findsNothing);
  });

  test('CF-190: mesma copy de vazio em todas as abas', () {
    for (final tab in NotificationTab.values) {
      expect(
        NotificationEmptyState.messageFor(tab),
        'Nenhuma notificação nesta aba ainda.',
      );
    }
  });
}
