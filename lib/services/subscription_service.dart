import 'package:crowdfans/api/api_urls.dart';
import 'package:crowdfans/services/http_service.dart';

/// Assinatura/membership de um artista.
class Subscription {
  const Subscription({
    required this.id,
    required this.userUid,
    required this.artistUid,
    required this.artistName,
    required this.isActive,
    required this.startDate,
    this.endDate,
  });

  final int id;
  final String userUid;
  final String artistUid;
  final String artistName;
  final bool isActive;
  final String startDate;
  final String? endDate;

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userUid: json['userUid'] as String? ?? '',
      artistUid: json['artistUid'] as String? ?? '',
      artistName: json['artistName'] as String? ?? '',
      isActive: json['isActive'] == true,
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String?,
    );
  }
}

class SubscriptionCheck {
  const SubscriptionCheck({required this.isSubscribed});

  final bool isSubscribed;

  factory SubscriptionCheck.fromJson(Object? json) {
    final map = json as Map<String, dynamic>? ?? {};
    return SubscriptionCheck(isSubscribed: map['isSubscribed'] == true);
  }
}

/// Memberships (`/api/v1/subscriptions`).
abstract final class SubscriptionService {
  static Future<SubscriptionCheck> checkSubscription(String artistUid) {
    return HttpService.request(
      ApiUrls.withParams(ApiUrls.subscriptionCheck, {'artistUid': artistUid}),
      parse: SubscriptionCheck.fromJson,
    );
  }

  static Future<Subscription> createSubscription(String artistUid) {
    return HttpService.request(
      ApiUrls.subscriptions,
      method: Method.post,
      body: {'artistUid': artistUid},
      parse: (json) =>
          Subscription.fromJson(json as Map<String, dynamic>? ?? {}),
    );
  }

  static Future<void> cancelSubscription(String artistUid) async {
    await HttpService.request<dynamic>(
      ApiUrls.withParams(ApiUrls.subscriptionCancel, {'artistUid': artistUid}),
      method: Method.delete,
    );
  }

  static Future<List<Subscription>> listSubscriptions() async {
    final data = await HttpService.request<Object?>(
      ApiUrls.subscriptions,
      parse: (json) => json,
    );
    if (data is List) {
      return [
        for (final item in data)
          Subscription.fromJson(item as Map<String, dynamic>),
      ];
    }
    if (data is Map && data['subscriptions'] is List) {
      return [
        for (final item in data['subscriptions'] as List)
          Subscription.fromJson(item as Map<String, dynamic>),
      ];
    }
    return const [];
  }
}
