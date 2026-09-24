import 'package:crowdfans/components/notifications/notification_filter_chip.dart';
import 'package:crowdfans/components/notifications/notification_item_card.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/notifications_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CF-159: chip compacto e accent em peso regular', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: Column(
            children: [
              SizedBox(
                height: 32,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Center(
                      child: NotificationFilterChip(
                        tab: NotificationTab.all,
                        selected: true,
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
              NotificationItemCard(
                item: const NotificationItem(
                  id: '1',
                  category: 'posts',
                  time: '21h',
                  unread: true,
                  avatarUris: [],
                  content: [
                    NotificationSegment(text: 'Artista 8', accent: true),
                    NotificationSegment(text: ' curtiu seu post'),
                  ],
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Todos'), findsOneWidget);
    expect(find.textContaining('Artista 8'), findsOneWidget);

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
    final accent = spans.where((s) => s.text == 'Artista 8').single;
    expect(accent.style?.fontWeight, FontWeight.w400);
  });
}
