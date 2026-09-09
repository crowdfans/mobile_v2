import 'package:crowdfans/api/api_urls.dart';
import 'package:crowdfans/services/http_service.dart';

/// Código de convite do viewer (`GET /api/v1/me/referral`).
class ReferralInfo {
  const ReferralInfo({
    required this.code,
    required this.referredCount,
    this.rewardCurrency,
    this.rewardPending = false,
    this.referredByUserUid,
  });

  final String code;
  final int referredCount;
  final String? rewardCurrency;
  final bool rewardPending;
  final String? referredByUserUid;

  factory ReferralInfo.fromJson(Object? json) {
    final map = (json as Map?)?.cast<String, dynamic>() ?? {};
    return ReferralInfo(
      code: map['code']?.toString() ?? '',
      referredCount: (map['referredCount'] as num?)?.toInt() ?? 0,
      rewardCurrency: map['rewardCurrency'] as String?,
      rewardPending: map['rewardPending'] == true,
      referredByUserUid: map['referredByUserUid'] as String?,
    );
  }
}

/// Indicações do usuário autenticado.
abstract final class ReferralService {
  static Future<ReferralInfo> getMyReferral() {
    return HttpService.request(
      ApiUrls.meReferral,
      parse: ReferralInfo.fromJson,
    );
  }
}
