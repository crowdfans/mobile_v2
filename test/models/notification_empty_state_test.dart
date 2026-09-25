import 'package:flutter_test/flutter_test.dart';
import 'package:crowdfans/components/notifications/notification_empty_state.dart';
import 'package:crowdfans/services/notifications_service.dart';

void main() {
  test('CF-190: vazio único conforme print', () {
    expect(
      NotificationEmptyState.messageFor(NotificationTab.posts),
      'Nenhuma notificação nesta aba ainda.',
    );
    expect(
      NotificationEmptyState.messageFor(NotificationTab.meet),
      NotificationEmptyState.messageFor(NotificationTab.clubs),
    );
  });
}
