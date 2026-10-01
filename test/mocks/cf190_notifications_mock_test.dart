import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/services/notifications_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CF-190: inbox mock off (CF-267); fixtures unitárias ainda válidas', () {
    expect(kUseCf190NotificationMocks, isFalse);

    final sections = CfTempMocks.notificationSections();
    expect(sections.map((s) => s.title), ['Agora', 'Hoje']);
    final allItems = [for (final s in sections) ...s.items];
    expect(allItems.any((i) => i.category == 'meet'), isTrue);

    final meetOnly = NotificationsService.filterSectionsByTab(
      sections,
      NotificationTab.meet,
    );
    expect(meetOnly.expand((s) => s.items).length, 1);
  });
}
