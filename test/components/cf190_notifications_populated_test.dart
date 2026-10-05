import 'package:crowdfans/components/notifications/notification_empty_state.dart';
import 'package:crowdfans/components/notifications/notification_filter_chip.dart';
import 'package:crowdfans/components/notifications/notification_item_card.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/services/notifications_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// CF-190 — central povoada por tipo (API CF-267), green / red / edge.
///
/// Fixtures locais espelham o shape prod (`sections` + `unread` + categories).
/// `kUseCf190NotificationMocks` permanece **false** (demock).

Map<String, dynamic> _prodShapedPayload() => {
      'sections': [
        {
          'id': 'agora',
          'title': 'Agora',
          'items': [
            {
              'id': 'ban-1',
              'category': 'clubs',
              'time': '21h',
              'unread': true,
              'avatarUris': ['https://example.com/a.png'],
              'content': [
                {'text': 'Você foi banido do fã clube de '},
                {'text': 'Ravi Tavares', 'accent': true},
              ],
              'targetRoute': '/fan-clubs/defend-return',
            },
            {
              'id': 'post-1',
              'category': 'posts',
              'time': '1m',
              'unread': true,
              'thumbnailUri': 'https://example.com/t.png',
              'avatarUris': ['https://example.com/b.png'],
              'content': [
                {'text': 'CF190 Artist', 'accent': true},
                {'text': ' publicou um novo post'},
              ],
              'targetRoute': '/artists/uid',
            },
          ],
        },
        {
          'id': 'hoje',
          'title': 'Hoje',
          'items': [
            {
              'id': 'meet-1',
              'category': 'meet',
              'time': '9m',
              'unread': true,
              'avatarUris': ['https://example.com/c.png'],
              'content': [
                {'text': 'Lembrete de Meet & Greet:', 'accent': true},
                {'text': ' sua chamada com '},
                {'text': 'Laís Costa', 'accent': true},
              ],
              'targetRoute': '/meet/events/1',
            },
            {
              'id': 'fanletter-1',
              'category': 'fanletter',
              'time': '12m',
              'unread': false,
              'avatarUris': ['https://example.com/d.png'],
              'content': [
                {'text': 'Mayra', 'accent': true},
                {'text': ' destacou sua Carta de Fã'},
              ],
              'targetRoute': '/fan-letter/gallery',
            },
            {
              'id': 'renewal-1',
              'category': 'system',
              'time': '48m',
              'unread': true,
              'avatarUris': ['https://example.com/e.png'],
              'content': [
                {'text': 'Sua assinatura de '},
                {'text': 'Marinhos', 'accent': true},
                {'text': ' renova em breve'},
              ],
              'targetRoute': '/artists/uid',
            },
          ],
        },
      ],
    };

List<NotificationSection> _parseSections(Map<String, dynamic> payload) {
  return [
    for (final item in payload['sections'] as List)
      NotificationSection.fromJson(item),
  ];
}

void main() {
  // --- GREEN ---
  test('CF-190 green: demock inbox (CF-267); parse shape prod por tipo', () {
    expect(kUseCf190NotificationMocks, isFalse);

    final sections = _parseSections(_prodShapedPayload());
    expect(sections.map((s) => s.title), ['Agora', 'Hoje']);

    final all = [for (final s in sections) ...s.items];
    final cats = all.map((i) => i.category).toSet();
    expect(
      cats,
      containsAll(<String>['clubs', 'posts', 'meet', 'fanletter', 'system']),
    );
    expect(all.where((i) => i.unread).length, greaterThanOrEqualTo(3));
    expect(
      all.every((i) => (i.targetRoute ?? '').isNotEmpty),
      isTrue,
    );
  });

  testWidgets(
    'CF-190 green: não-lida = ponto lilás (não só cor do texto)',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: NotificationItemCard(
              item: const NotificationItem(
                id: 'u1',
                category: 'posts',
                time: '1m',
                unread: true,
                avatarUris: [],
                content: [
                  NotificationSegment(text: 'Artista', accent: true),
                  NotificationSegment(text: ' publicou'),
                ],
              ),
              onPressed: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.bySemanticsLabel(RegExp(r'Não lida')), findsWidgets);

      final colors = AppColors.light;
      final unreadDot = find.byWidgetPredicate((w) {
        if (w is! Container) return false;
        if (w.margin != const EdgeInsets.only(top: 6)) return false;
        final d = w.decoration;
        if (d is! BoxDecoration) return false;
        return d.shape == BoxShape.circle && d.color == colors.primary;
      });
      expect(unreadDot, findsOneWidget);
    },
  );

  testWidgets('CF-190 green: Meet card verde + accent verde', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: NotificationItemCard(
            item: const NotificationItem(
              id: 'meet',
              category: 'meet',
              time: '9m',
              unread: true,
              avatarUris: [],
              content: [
                NotificationSegment(
                  text: 'Lembrete de Meet & Greet:',
                  accent: true,
                ),
              ],
            ),
            onPressed: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    final material = tester.widget<Material>(
      find
          .descendant(
            of: find.byType(NotificationItemCard),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(material.color, AppPalette.green50);
  });

  // --- RED ---
  test('CF-190 red: aba sem itens → filtro vazio (empty state)', () {
    final sections = _parseSections(_prodShapedPayload());
    final postsOnly = NotificationsService.filterSectionsByTab(
      sections,
      NotificationTab.posts,
    );
    expect(postsOnly.expand((s) => s.items).length, 1);

    final emptyClubs = NotificationsService.filterSectionsByTab(
      const [
        NotificationSection(
          id: 'agora',
          title: 'Agora',
          items: [
            NotificationItem(
              id: 'p',
              category: 'posts',
              time: '1m',
              avatarUris: [],
              content: [NotificationSegment(text: 'só posts')],
            ),
          ],
        ),
      ],
      NotificationTab.clubs,
    );
    expect(emptyClubs, isEmpty);
  });

  testWidgets(
    'CF-190 red: empty copy do print em qualquer aba',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: const Scaffold(
            body: NotificationEmptyState(tab: NotificationTab.meet),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Nenhuma notificação nesta aba ainda.'), findsOneWidget);
      expect(find.byType(NotificationItemCard), findsNothing);
    },
  );

  test('CF-190 red: sem unread no JSON → unread false', () {
    final item = NotificationItem.fromJson({
      'id': 'x',
      'category': 'posts',
      'time': '1m',
      'avatarUris': <String>[],
      'content': [
        {'text': 'oi'},
      ],
    });
    expect(item.unread, isFalse);
  });

  // --- EDGE ---
  testWidgets(
    'CF-190 edge: rótulos das abas legíveis (Cartas, Meet & Greet)',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: SizedBox(
              height: 32,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final tab in NotificationTab.values)
                    if (tab != NotificationTab.system)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: NotificationFilterChip(
                          tab: tab,
                          selected: tab == NotificationTab.all,
                          onPressed: () {},
                        ),
                      ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Todos'), findsOneWidget);
      expect(find.text('Meet & Greet'), findsOneWidget);
      expect(find.text('Cartas'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  test('CF-190 edge: fixtures unitárias ainda cobrem print após demock', () {
    expect(kUseCf190NotificationMocks, isFalse);
    final fixtures = CfTempMocks.notificationSections();
    expect(fixtures.map((s) => s.title), ['Agora', 'Hoje']);
    final meet = NotificationsService.filterSectionsByTab(
      fixtures,
      NotificationTab.meet,
    );
    expect(meet.expand((s) => s.items).length, 1);
  });

  testWidgets(
    'CF-190 edge: texto longo no accent não estoura (sem exception)',
    (tester) async {
      const long =
          'Nome Extremamente Longo De Artista Para Quebrar Layout Se Overflow';
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: SizedBox(
              width: 320,
              child: NotificationItemCard(
                item: const NotificationItem(
                  id: 'long',
                  category: 'clubs',
                  time: '14d',
                  unread: false,
                  avatarUris: [],
                  content: [
                    NotificationSegment(text: long, accent: true),
                    NotificationSegment(text: ' entrou no fã clube'),
                  ],
                ),
                onPressed: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.textContaining('Nome Extremamente Longo'), findsOneWidget);
    },
  );
}
