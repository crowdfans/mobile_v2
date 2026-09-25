import 'package:crowdfans/components/notifications/notification_item_card.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/notifications_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CF-190: Meet usa accent verde e card verde', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: NotificationItemCard(
            item: const NotificationItem(
              id: 'meet-1',
              category: 'meet',
              time: '9m',
              unread: true,
              avatarUris: [],
              content: [
                NotificationSegment(
                  text: 'Lembrete de Meet & Greet:',
                  accent: true,
                ),
                NotificationSegment(text: ' sua chamada com '),
                NotificationSegment(text: 'Laís Costa', accent: true),
              ],
            ),
            onPressed: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.textContaining('Lembrete de Meet & Greet'), findsOneWidget);
    expect(find.bySemanticsLabel('Não lida'), findsOneWidget);

    final material = tester.widget<Material>(
      find.descendant(
        of: find.byType(NotificationItemCard),
        matching: find.byType(Material),
      ).first,
    );
    expect(material.color, AppPalette.green50);

    final rich = tester.widget<RichText>(
      find.descendant(
        of: find.byType(NotificationItemCard),
        matching: find.byType(RichText),
      ).first,
    );
    final spans = <TextSpan>[];
    void collect(InlineSpan span) {
      if (span is TextSpan) {
        spans.add(span);
        final kids = span.children;
        if (kids != null) {
          for (final child in kids) {
            collect(child);
          }
        }
      }
    }

    collect(rich.text);
    final accent = spans
        .where((s) => s.text == 'Lembrete de Meet & Greet:')
        .single;
    expect(accent.style?.color, AppPalette.green700);
    expect(accent.style?.fontWeight, FontWeight.w600);
  });
}
