import 'package:crowdfans/api/api_urls.dart';
import 'package:crowdfans/services/http_service.dart';

class NotificationSegment {
  const NotificationSegment({required this.text, this.accent = false});

  final String text;
  final bool accent;

  factory NotificationSegment.fromJson(Object? json) {
    final map = json as Map<String, dynamic>? ?? {};
    return NotificationSegment(
      text: map['text'] as String? ?? '',
      accent: map['accent'] == true,
    );
  }
}

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.category,
    required this.time,
    required this.avatarUris,
    required this.content,
    this.thumbnailUri,
    this.targetRoute,
  });

  final String id;
  final String category;
  final String time;
  final String? thumbnailUri;
  final List<String> avatarUris;
  final List<NotificationSegment> content;
  final String? targetRoute;

  factory NotificationItem.fromJson(Object? json) {
    final map = json as Map<String, dynamic>? ?? {};
    return NotificationItem(
      id: map['id'] as String? ?? '',
      category: map['category'] as String? ?? '',
      time: map['time'] as String? ?? '',
      thumbnailUri: map['thumbnailUri'] as String?,
      avatarUris: [
        for (final item in map['avatarUris'] as List? ?? const [])
          item.toString(),
      ],
      content: [
        for (final item in map['content'] as List? ?? const [])
          NotificationSegment.fromJson(item),
      ],
      targetRoute: map['targetRoute'] as String?,
    );
  }
}

class NotificationSection {
  const NotificationSection({
    required this.id,
    required this.title,
    required this.items,
  });

  final String id;
  final String title;
  final List<NotificationItem> items;

  factory NotificationSection.fromJson(Object? json) {
    final map = json as Map<String, dynamic>? ?? {};
    return NotificationSection(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      items: [
        for (final item in map['items'] as List? ?? const [])
          NotificationItem.fromJson(item),
      ],
    );
  }
}

enum NotificationTab { all, posts, clubs, meet, fanletter, system }

/// Inbox autenticada (`GET /api/v1/notifications`).
abstract final class NotificationsService {
  static Future<List<NotificationSection>> getNotifications() async {
    return HttpService.request<List<NotificationSection>>(
      ApiUrls.notifications,
      parse: (json) {
        if (json is List) {
          return [for (final item in json) NotificationSection.fromJson(item)];
        }
        final map = json as Map<String, dynamic>? ?? {};
        return [
          for (final item in map['sections'] as List? ?? const [])
            NotificationSection.fromJson(item),
        ];
      },
    );
  }

  static List<NotificationSection> filterSectionsByTab(
    List<NotificationSection> sections,
    NotificationTab tab,
  ) {
    if (tab == NotificationTab.all) {
      return sections;
    }
    final category = tab == NotificationTab.fanletter ? 'fanletter' : tab.name;
    return [
      for (final section in sections)
        if (section.items.any((item) => item.category == category))
          NotificationSection(
            id: section.id,
            title: section.title,
            items: [
              for (final item in section.items)
                if (item.category == category) item,
            ],
          ),
    ];
  }
}
