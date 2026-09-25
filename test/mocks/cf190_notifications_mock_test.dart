import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/services/notifications_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CF-190 mock em cf_temp_mocks: Agora/Hoje, categorias e não-lida', () {
    expect(kUseCfTempMocks, isTrue);
    expect(kUseCf190NotificationMocks, isTrue);
    expect(kCf190MockEmpty, isFalse);

    final sections = CfTempMocks.notificationSections();
    expect(sections.map((s) => s.title), ['Agora', 'Hoje']);

    final allItems = [for (final s in sections) ...s.items];
    expect(allItems.where((i) => i.unread), isNotEmpty);
    expect(allItems.any((i) => i.category == 'posts'), isTrue);
    expect(allItems.any((i) => i.category == 'clubs'), isTrue);
    expect(allItems.any((i) => i.category == 'meet'), isTrue);
    expect(allItems.any((i) => i.category == 'fanletter'), isTrue);
    expect(allItems.any((i) => i.category == 'system'), isTrue);

    final meet = allItems.where((i) => i.category == 'meet').single;
    expect(
      meet.content.map((c) => c.text).join(),
      contains('Lembrete de Meet & Greet'),
    );

    final postsOnly = NotificationsService.filterSectionsByTab(
      sections,
      NotificationTab.posts,
    );
    expect(
      postsOnly.expand((s) => s.items).every((i) => i.category == 'posts'),
      isTrue,
    );

    final meetOnly = NotificationsService.filterSectionsByTab(
      sections,
      NotificationTab.meet,
    );
    expect(meetOnly.expand((s) => s.items).length, 1);
  });
}
