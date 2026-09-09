import 'package:crowdfans/api/api_urls.dart';
import 'package:crowdfans/services/http_service.dart';

/// Pedido de saque PIX.
class WithdrawalItem {
  const WithdrawalItem({
    required this.id,
    required this.amount,
    required this.pixKey,
    required this.status,
    required this.createdAt,
  });

  final int id;
  final num amount;
  final String pixKey;
  final String status;
  final String createdAt;

  factory WithdrawalItem.fromJson(Object? json) {
    final map = (json as Map?)?.cast<String, dynamic>() ?? {};
    return WithdrawalItem(
      id: (map['id'] as num?)?.toInt() ?? 0,
      amount: map['amount'] as num? ?? 0,
      pixKey: map['pixKey']?.toString() ?? '',
      status: map['status']?.toString() ?? '',
      createdAt: map['createdAt']?.toString() ?? '',
    );
  }
}

/// Saldo de ganhos do artista.
class EarningsSnapshot {
  const EarningsSnapshot({
    this.available = 0,
    this.pending = 0,
    this.sharePercent = 70,
    this.withdrawals = const [],
  });

  final num available;
  final num pending;
  final num sharePercent;
  final List<WithdrawalItem> withdrawals;

  factory EarningsSnapshot.fromJson(Object? json) {
    final map = (json as Map?)?.cast<String, dynamic>() ?? {};
    return EarningsSnapshot(
      available: map['available'] as num? ?? 0,
      pending: map['pending'] as num? ?? 0,
      sharePercent: map['sharePercent'] as num? ?? 70,
      withdrawals: [
        for (final item in map['withdrawals'] as List? ?? const [])
          WithdrawalItem.fromJson(item),
      ],
    );
  }
}

/// Ganhos e saque PIX (`GET /api/v1/me/earnings`).
abstract final class EarningsService {
  static Future<EarningsSnapshot> getEarnings() {
    return HttpService.request(
      ApiUrls.meEarnings,
      parse: EarningsSnapshot.fromJson,
    );
  }

  static Future<WithdrawalItem> requestWithdrawal(num amount, String pixKey) {
    return HttpService.request(
      ApiUrls.meEarningsWithdrawals,
      method: Method.post,
      body: {'amount': amount, 'pixKey': pixKey},
      parse: WithdrawalItem.fromJson,
    );
  }
}
