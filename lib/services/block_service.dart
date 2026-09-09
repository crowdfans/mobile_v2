import 'package:crowdfans/api/api_urls.dart';
import 'package:crowdfans/services/http_service.dart';

/// Usuário bloqueado pelo viewer.
class BlockedUser {
  const BlockedUser({
    required this.userUid,
    required this.displayName,
    required this.handle,
    required this.photoUrl,
    required this.blockedAt,
  });

  final String userUid;
  final String displayName;
  final String handle;
  final String photoUrl;
  final String blockedAt;

  factory BlockedUser.fromJson(Map<String, dynamic> json) {
    return BlockedUser(
      userUid: json['userUid'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      handle: json['handle'] as String? ?? '',
      photoUrl: json['photoUrl'] as String? ?? '',
      blockedAt: json['blockedAt'] as String? ?? '',
    );
  }
}

/// Bloqueios (`/api/v1/blocks`).
abstract final class BlockService {
  static Future<List<BlockedUser>> listBlockedUsers() async {
    final data = await HttpService.request<Map<String, dynamic>>(
      ApiUrls.blocks,
      parse: (json) => (json as Map?)?.cast<String, dynamic>() ?? {},
    );
    return [
      for (final item in data['blocks'] as List? ?? const [])
        BlockedUser.fromJson(item as Map<String, dynamic>),
    ];
  }

  static Future<void> blockUser(String userUid) async {
    await HttpService.request<dynamic>(
      ApiUrls.withParams(ApiUrls.blockUser, {'userUid': userUid}),
      method: Method.post,
    );
  }

  static Future<void> unblockUser(String userUid) async {
    await HttpService.request<dynamic>(
      ApiUrls.withParams(ApiUrls.blockUser, {'userUid': userUid}),
      method: Method.delete,
    );
  }
}
