import 'package:crowdfans/components/notifications/notification_empty_state.dart';
import 'package:crowdfans/components/notifications/notification_filter_chip.dart';
import 'package:crowdfans/components/notifications/notification_item_card.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/notifications_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

List<TextSpan> _collectSpans(InlineSpan root) {
  final spans = <TextSpan>[];
  void walk(InlineSpan span) {
    if (span is TextSpan) {
      spans.add(span);
      final kids = span.children;
      if (kids != null) {
        for (final child in kids) {
          walk(child);
        }
      }
    }
  }

  walk(root);
  return spans;
}

TextSpan _accentSpan(WidgetTester tester, String text) {
  final richFinders = find.descendant(
    of: find.byType(NotificationItemCard),
    matching: find.byType(RichText),
  );
  for (final element in richFinders.evaluate()) {
    final rich = element.widget as RichText;
    final match = _collectSpans(rich.text).where((s) => s.text == text);
    if (match.isNotEmpty) {
      return match.single;
    }
  }
  throw StateError('TextSpan "$text" not found in NotificationItemCard');
}

Widget _chipRow({
  required NotificationTab selected,
  double height = 32,
}) {
  return SizedBox(
    height: height,
    child: ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        for (final tab in NotificationTab.values)
          if (tab != NotificationTab.system) ...[
            Center(
              child: NotificationFilterChip(
                tab: tab,
                selected: tab == selected,
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 6),
          ],
      ],
    ),
  );
}

void main() {
  // --- GREEN: print — chips compactos + accent só por cor ---
  testWidgets(
    'CF-159 green: chip compacto (≤32) e centralizado verticalmente',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(body: _chipRow(selected: NotificationTab.all)),
        ),
      );
      await tester.pump();

      expect(find.text('Todos'), findsOneWidget);
      expect(find.text('Posts'), findsOneWidget);
      expect(find.text('Fã Clubes'), findsOneWidget);

      final chip = tester.getSize(find.byType(NotificationFilterChip).first);
      expect(chip.height, lessThanOrEqualTo(32));

      final rowBox = tester.getRect(find.byType(ListView));
      final chipBox = tester.getRect(find.byType(NotificationFilterChip).first);
      final rowMid = rowBox.top + rowBox.height / 2;
      final chipMid = chipBox.top + chipBox.height / 2;
      expect((chipMid - rowMid).abs(), lessThanOrEqualTo(1.0));
    },
  );

  testWidgets(
    'CF-159 green: accent "Artista 8" em regular e cor primary',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: NotificationItemCard(
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
          ),
        ),
      );
      await tester.pump();

      final colors = AppColors.light;
      final accent = _accentSpan(tester, 'Artista 8');
      expect(accent.style?.fontWeight, FontWeight.w400);
      expect(accent.style?.color, colors.primary);

      final plain = _accentSpan(tester, ' curtiu seu post');
      expect(plain.style?.fontWeight, FontWeight.w400);
      expect(plain.style?.color, colors.textPrimary);
    },
  );

  // --- RED: vazio / chip não selecionado / sem bold em nome ---
  testWidgets(
    'CF-159 red: filtro sem itens mostra empty state (não lista)',
    (tester) async {
      const sections = [
        NotificationSection(
          id: 'hoje',
          title: 'Hoje',
          items: [
            NotificationItem(
              id: 'p1',
              category: 'posts',
              time: '1m',
              avatarUris: [],
              content: [NotificationSegment(text: 'só posts')],
            ),
          ],
        ),
      ];
      final filtered = NotificationsService.filterSectionsByTab(
        sections,
        NotificationTab.clubs,
      );
      expect(filtered, isEmpty);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: const Scaffold(
            body: NotificationEmptyState(tab: NotificationTab.clubs),
          ),
        ),
      );
      await tester.pump();

      expect(
        find.text(NotificationEmptyState.emptyMessage),
        findsOneWidget,
      );
      expect(find.byType(NotificationItemCard), findsNothing);
    },
  );

  testWidgets(
    'CF-159 red: chip não selecionado não usa fill primary',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: NotificationFilterChip(
              tab: NotificationTab.posts,
              selected: false,
              onPressed: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      final colors = AppColors.light;
      final material = tester.widget<Material>(
        find.descendant(
          of: find.byType(NotificationFilterChip),
          matching: find.byType(Material),
        ),
      );
      expect(material.color, isNot(colors.primary));
      expect(material.color, colors.surface);
    },
  );

  // --- EDGE: texto longo, unread+thumb, row height apertada ---
  testWidgets(
    'CF-159 edge: accent com texto longo permanece regular',
    (tester) async {
      const longName =
          'Artista Com Nome Extremamente Longo Para Quebrar Layout Se Bold';
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: NotificationItemCard(
              item: const NotificationItem(
                id: 'long',
                category: 'clubs',
                time: '14d',
                unread: false,
                avatarUris: [],
                content: [
                  NotificationSegment(text: longName, accent: true),
                  NotificationSegment(
                    text: ' publicou no Fã Clube que você segue',
                  ),
                ],
              ),
              onPressed: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      final accent = _accentSpan(tester, longName);
      expect(accent.style?.fontWeight, FontWeight.w400);
      expect(accent.style?.fontWeight, isNot(FontWeight.w700));
      expect(accent.style?.fontWeight, isNot(FontWeight.bold));
    },
  );

  testWidgets(
    'CF-159 edge: unread + thumbnail não altera peso do accent',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: NotificationItemCard(
              item: const NotificationItem(
                id: 'thumb',
                category: 'posts',
                time: '2h',
                unread: true,
                avatarUris: [],
                thumbnailUri: 'https://example.com/t.png',
                content: [
                  NotificationSegment(text: 'Mayra', accent: true),
                  NotificationSegment(text: ' curtiu seu post'),
                ],
              ),
              onPressed: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      // Ponto de não-lida presente (Container 8×8) junto do thumb.
      expect(find.byType(Image), findsOneWidget);
      final accent = _accentSpan(tester, 'Mayra');
      expect(accent.style?.fontWeight, FontWeight.w400);
      expect(accent.style?.color, AppColors.light.primary);
    },
  );

  testWidgets(
    'CF-159 edge: chip cabe em faixa de 28px sem overflow',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: _chipRow(selected: NotificationTab.meet, height: 28),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      final chip = tester.getSize(find.byType(NotificationFilterChip).first);
      expect(chip.height, lessThanOrEqualTo(28));
    },
  );
}
