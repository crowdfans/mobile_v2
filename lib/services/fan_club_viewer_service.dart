import 'package:crowdfans/api/api_urls.dart';
import 'package:crowdfans/services/http_service.dart';

/// Comunidade que o viewer possui ou modera.
class FanClubModerationCommunity {
  const FanClubModerationCommunity({
    required this.artistUid,
    required this.artistName,
    required this.artistPhotoUrl,
    required this.memberCount,
    required this.pendingAppealsCount,
    required this.activeStrikesCount,
    required this.expulsionsCount,
  });

  final String artistUid;
  final String artistName;
  final String artistPhotoUrl;
  final int memberCount;
  final int pendingAppealsCount;
  final int activeStrikesCount;
  final int expulsionsCount;

  factory FanClubModerationCommunity.fromJson(Map<String, dynamic> json) {
    return FanClubModerationCommunity(
      artistUid: json['artistUid'] as String? ?? '',
      artistName: json['artistName'] as String? ?? '',
      artistPhotoUrl: json['artistPhotoUrl'] as String? ?? '',
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
      pendingAppealsCount: (json['pendingAppealsCount'] as num?)?.toInt() ?? 0,
      activeStrikesCount: (json['activeStrikesCount'] as num?)?.toInt() ?? 0,
      expulsionsCount: (json['expulsionsCount'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Expulsão/contestação do viewer autenticado.
class FanClubContestation {
  const FanClubContestation({
    required this.artistUid,
    required this.artistName,
    required this.artistPhotoUrl,
    required this.expulsionId,
    required this.reason,
    required this.expelledAt,
    this.appealStatus,
    this.appealDefense,
    this.appealRejectionReason,
  });

  final String artistUid;
  final String artistName;
  final String artistPhotoUrl;
  final String expulsionId;
  final String reason;
  final String expelledAt;
  final String? appealStatus;
  final String? appealDefense;
  final String? appealRejectionReason;

  factory FanClubContestation.fromJson(Map<String, dynamic> json) {
    final appeal = json['appeal'] as Map<String, dynamic>?;
    return FanClubContestation(
      artistUid: json['artistUid'] as String? ?? '',
      artistName: json['artistName'] as String? ?? '',
      artistPhotoUrl: json['artistPhotoUrl'] as String? ?? '',
      expulsionId: json['expulsionId'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      expelledAt: json['expelledAt'] as String? ?? '',
      appealStatus: appeal?['status'] as String?,
      appealDefense: appeal?['defense'] as String?,
      appealRejectionReason: appeal?['rejectionReason'] as String?,
    );
  }
}

/// Clubs que o viewer possui, modera ou contestou.
abstract final class FanClubViewerService {
  static Future<List<FanClubModerationCommunity>>
  listMyModerationCommunities() {
    return HttpService.request(
      ApiUrls.meFanclubModeration,
      parse: (json) {
        final map = (json as Map?)?.cast<String, dynamic>() ?? {};
        return [
          for (final item in map['communities'] as List? ?? const [])
            FanClubModerationCommunity.fromJson(item as Map<String, dynamic>),
        ];
      },
    );
  }

  static Future<List<FanClubContestation>> listMyContestations() {
    return HttpService.request(
      ApiUrls.meFanclubContestations,
      parse: (json) {
        final map = (json as Map?)?.cast<String, dynamic>() ?? {};
        return [
          for (final item in map['items'] as List? ?? const [])
            FanClubContestation.fromJson(item as Map<String, dynamic>),
        ];
      },
    );
  }
}
