import 'package:crowdfans/api/api_error.dart';
import 'package:crowdfans/api/api_urls.dart';
import 'package:crowdfans/services/http_service.dart';

/// Metadados do fan club (`GET /artist/:artistUid/fanclub`).
class ArtistFanClub {
  const ArtistFanClub({
    required this.id,
    required this.name,
    required this.description,
    required this.artistUid,
    required this.artistName,
    required this.isActive,
    required this.memberCount,
    required this.isMember,
    this.viewerIsModerator = false,
    this.viewerIsOwner = false,
    this.viewerIsExpelled = false,
    this.moderators = const [],
  });

  final int id;
  final String name;
  final String description;
  final String artistUid;
  final String artistName;
  final bool isActive;
  final int memberCount;
  final bool isMember;
  final bool viewerIsModerator;
  final bool viewerIsOwner;
  final bool viewerIsExpelled;
  final List<FanClubModerator> moderators;

  factory ArtistFanClub.fromJson(Map<String, dynamic> json) {
    return ArtistFanClub(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      artistUid: json['artistUid'] as String? ?? '',
      artistName: json['artistName'] as String? ?? '',
      isActive: json['isActive'] == true,
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
      isMember: json['isMember'] == true,
      viewerIsModerator: json['viewerIsModerator'] == true,
      viewerIsOwner: json['viewerIsOwner'] == true,
      viewerIsExpelled: json['viewerIsExpelled'] == true,
      moderators: [
        for (final item in json['moderators'] as List? ?? const [])
          FanClubModerator.fromJson(item as Map<String, dynamic>),
      ],
    );
  }
}

/// Moderador listado no fã clube.
class FanClubModerator {
  const FanClubModerator({
    required this.userUid,
    required this.handle,
    required this.displayName,
    required this.photoUrl,
    required this.role,
  });

  final String userUid;
  final String handle;
  final String displayName;
  final String photoUrl;
  final String role;

  bool get isOwner => role == 'owner';

  factory FanClubModerator.fromJson(Map<String, dynamic> json) {
    return FanClubModerator(
      userUid: json['userUid'] as String? ?? '',
      handle: json['handle'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      photoUrl: json['photoUrl'] as String? ?? '',
      role: json['role'] as String? ?? 'moderator',
    );
  }
}

/// Pedido para virar moderador.
class FanClubModeratorRequest {
  const FanClubModeratorRequest({
    required this.requestId,
    required this.requesterUid,
    required this.displayName,
    required this.handle,
    required this.photoUrl,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  final String requestId;
  final String requesterUid;
  final String displayName;
  final String handle;
  final String photoUrl;
  final String reason;
  final String status;
  final String createdAt;

  factory FanClubModeratorRequest.fromJson(Map<String, dynamic> json) {
    return FanClubModeratorRequest(
      requestId: json['requestId'] as String? ?? '',
      requesterUid: json['requesterUid'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      handle: json['handle'] as String? ?? '',
      photoUrl: json['photoUrl'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      status: json['status'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}

/// Strike aplicado a um membro.
class FanClubStrike {
  const FanClubStrike({
    required this.strikeId,
    required this.targetUid,
    required this.displayName,
    required this.handle,
    required this.photoUrl,
    required this.reason,
    required this.remainingChances,
    required this.issuedByUid,
    required this.createdAt,
  });

  final String strikeId;
  final String targetUid;
  final String displayName;
  final String handle;
  final String photoUrl;
  final String reason;
  final int remainingChances;
  final String issuedByUid;
  final String createdAt;

  factory FanClubStrike.fromJson(Map<String, dynamic> json) {
    return FanClubStrike(
      strikeId: json['strikeId'] as String? ?? '',
      targetUid: json['targetUid'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      handle: json['handle'] as String? ?? '',
      photoUrl: json['photoUrl'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      remainingChances: (json['remainingChances'] as num?)?.toInt() ?? 0,
      issuedByUid: json['issuedByUid'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}

/// Expulsão de um membro.
class FanClubExpulsion {
  const FanClubExpulsion({
    required this.expulsionId,
    required this.targetUid,
    required this.displayName,
    required this.handle,
    required this.photoUrl,
    required this.reason,
    required this.issuedByUid,
    required this.createdAt,
  });

  final String expulsionId;
  final String targetUid;
  final String displayName;
  final String handle;
  final String photoUrl;
  final String reason;
  final String issuedByUid;
  final String createdAt;

  factory FanClubExpulsion.fromJson(Map<String, dynamic> json) {
    return FanClubExpulsion(
      expulsionId: json['expulsionId'] as String? ?? '',
      targetUid: json['targetUid'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      handle: json['handle'] as String? ?? '',
      photoUrl: json['photoUrl'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      issuedByUid: json['issuedByUid'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}

/// Apelação de expulsão.
class FanClubAppeal {
  const FanClubAppeal({
    required this.appealId,
    required this.expulsionId,
    required this.requesterUid,
    required this.displayName,
    required this.handle,
    required this.photoUrl,
    required this.defense,
    required this.status,
    required this.createdAt,
    this.rejectionReason,
  });

  final String appealId;
  final String expulsionId;
  final String requesterUid;
  final String displayName;
  final String handle;
  final String photoUrl;
  final String defense;
  final String status;
  final String? rejectionReason;
  final String createdAt;

  factory FanClubAppeal.fromJson(Map<String, dynamic> json) {
    return FanClubAppeal(
      appealId: json['appealId'] as String? ?? '',
      expulsionId: json['expulsionId'] as String? ?? '',
      requesterUid: json['requesterUid'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      handle: json['handle'] as String? ?? '',
      photoUrl: json['photoUrl'] as String? ?? '',
      defense: json['defense'] as String? ?? '',
      status: json['status'] as String? ?? '',
      rejectionReason: json['rejectionReason'] as String?,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}

class FanClubFeedPost {
  const FanClubFeedPost({
    required this.postId,
    required this.content,
    required this.createdAt,
    this.title,
    this.imageUrl,
    this.type,
    this.isExclusive = false,
    this.likesCount = 0,
    this.commentsCount = 0,
  });

  final String postId;
  final String? title;
  final String content;
  final String? imageUrl;
  final String? type;
  final bool isExclusive;
  final String createdAt;
  final int likesCount;
  final int commentsCount;

  factory FanClubFeedPost.fromJson(Map<String, dynamic> json) {
    return FanClubFeedPost(
      postId: json['postId'] as String? ?? '',
      title: json['title'] as String?,
      content: json['content'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      type: json['type'] as String?,
      isExclusive: json['isExclusive'] == true,
      createdAt: json['createdAt'] as String? ?? '',
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
      commentsCount: (json['commentsCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class ArtistFanClubFeed {
  const ArtistFanClubFeed({required this.fanClub, this.posts = const []});

  final ArtistFanClub fanClub;
  final List<FanClubFeedPost> posts;

  factory ArtistFanClubFeed.fromJson(Object? json) {
    final map = json as Map<String, dynamic>? ?? {};
    final clubJson = map['fanClub'] as Map<String, dynamic>? ?? {};
    return ArtistFanClubFeed(
      fanClub: ArtistFanClub.fromJson(clubJson),
      posts: [
        for (final item in map['posts'] as List? ?? const [])
          FanClubFeedPost.fromJson(item as Map<String, dynamic>),
      ],
    );
  }
}

/// Fan club do artista (`/api/v1/artist/:artistUid/fanclub`).
abstract final class FanClubService {
  static Future<ArtistFanClubFeed?> getArtistFanClubFeed(
    String artistUid, {
    int page = 1,
    int pageSize = 20,
  }) async {
    final params = Uri(
      queryParameters: {'page': '$page', 'pageSize': '$pageSize'},
    );
    try {
      return await HttpService.request(
        '${ApiUrls.withParams(ApiUrls.artistFanclub, {'artistUid': artistUid})}?${params.query}',
        parse: ArtistFanClubFeed.fromJson,
      );
    } on ApiError catch (error) {
      if (error.status == 404) {
        return null;
      }
      rethrow;
    }
  }

  static Future<ArtistFanClub?> getArtistFanClub(String artistUid) async {
    final feed = await getArtistFanClubFeed(artistUid, pageSize: 1);
    return feed?.fanClub;
  }

  static Future<FanClubModerator> addFanClubModerator(
    String artistUid,
    String userUid,
  ) {
    return HttpService.request(
      ApiUrls.withParams(ApiUrls.artistFanclubModerators, {
        'artistUid': artistUid,
      }),
      method: Method.post,
      body: {'userUid': userUid},
      parse: (json) =>
          FanClubModerator.fromJson(json as Map<String, dynamic>? ?? {}),
    );
  }

  static Future<void> removeFanClubModerator(
    String artistUid,
    String userUid,
  ) async {
    await HttpService.request<dynamic>(
      ApiUrls.withParams(ApiUrls.artistFanclubModerator, {
        'artistUid': artistUid,
        'userUid': userUid,
      }),
      method: Method.delete,
    );
  }

  static Future<FanClubModeratorRequest> requestFanClubModeration(
    String artistUid,
    String reason,
  ) {
    return HttpService.request(
      ApiUrls.withParams(ApiUrls.artistFanclubModeratorRequests, {
        'artistUid': artistUid,
      }),
      method: Method.post,
      body: {'reason': reason},
      parse: (json) =>
          FanClubModeratorRequest.fromJson(json as Map<String, dynamic>? ?? {}),
    );
  }

  static Future<List<FanClubModeratorRequest>> listFanClubModeratorRequests(
    String artistUid, {
    String status = 'pending',
  }) {
    final path = ApiUrls.withParams(ApiUrls.artistFanclubModeratorRequests, {
      'artistUid': artistUid,
    });
    return HttpService.request(
      '$path?status=${Uri.encodeQueryComponent(status)}',
      parse: (json) {
        final map = (json as Map?)?.cast<String, dynamic>() ?? {};
        return [
          for (final item in map['requests'] as List? ?? const [])
            FanClubModeratorRequest.fromJson(item as Map<String, dynamic>),
        ];
      },
    );
  }

  static Future<FanClubModerator> approveFanClubModeratorRequest(
    String artistUid,
    String requestId,
  ) {
    return HttpService.request(
      ApiUrls.withParams(ApiUrls.artistFanclubModeratorRequestApprove, {
        'artistUid': artistUid,
        'requestId': requestId,
      }),
      method: Method.post,
      parse: (json) =>
          FanClubModerator.fromJson(json as Map<String, dynamic>? ?? {}),
    );
  }

  static Future<void> rejectFanClubModeratorRequest(
    String artistUid,
    String requestId,
  ) async {
    await HttpService.request<dynamic>(
      ApiUrls.withParams(ApiUrls.artistFanclubModeratorRequestReject, {
        'artistUid': artistUid,
        'requestId': requestId,
      }),
      method: Method.post,
    );
  }

  static Future<FanClubStrike> issueFanClubStrike(
    String artistUid,
    String userUid,
    String reason, {
    String? postId,
  }) {
    return HttpService.request(
      ApiUrls.withParams(ApiUrls.artistFanclubStrikes, {
        'artistUid': artistUid,
      }),
      method: Method.post,
      body: {
        'userUid': userUid,
        'reason': reason,
        'postId': ?postId,
      },
      parse: (json) =>
          FanClubStrike.fromJson(json as Map<String, dynamic>? ?? {}),
    );
  }

  static Future<List<FanClubStrike>> listFanClubStrikes(String artistUid) {
    return HttpService.request(
      ApiUrls.withParams(ApiUrls.artistFanclubStrikes, {
        'artistUid': artistUid,
      }),
      parse: (json) {
        final map = (json as Map?)?.cast<String, dynamic>() ?? {};
        return [
          for (final item in map['strikes'] as List? ?? const [])
            FanClubStrike.fromJson(item as Map<String, dynamic>),
        ];
      },
    );
  }

  static Future<FanClubExpulsion> issueFanClubExpulsion(
    String artistUid,
    String userUid,
    String reason, {
    String? postId,
  }) {
    return HttpService.request(
      ApiUrls.withParams(ApiUrls.artistFanclubExpulsions, {
        'artistUid': artistUid,
      }),
      method: Method.post,
      body: {
        'userUid': userUid,
        'reason': reason,
        'postId': ?postId,
      },
      parse: (json) =>
          FanClubExpulsion.fromJson(json as Map<String, dynamic>? ?? {}),
    );
  }

  static Future<List<FanClubExpulsion>> listFanClubExpulsions(
    String artistUid,
  ) {
    return HttpService.request(
      ApiUrls.withParams(ApiUrls.artistFanclubExpulsions, {
        'artistUid': artistUid,
      }),
      parse: (json) {
        final map = (json as Map?)?.cast<String, dynamic>() ?? {};
        return [
          for (final item in map['expulsions'] as List? ?? const [])
            FanClubExpulsion.fromJson(item as Map<String, dynamic>),
        ];
      },
    );
  }

  static Future<FanClubAppeal> createFanClubAppeal(
    String artistUid,
    String defense,
  ) {
    return HttpService.request(
      ApiUrls.withParams(ApiUrls.artistFanclubAppeals, {
        'artistUid': artistUid,
      }),
      method: Method.post,
      body: {'defense': defense},
      parse: (json) =>
          FanClubAppeal.fromJson(json as Map<String, dynamic>? ?? {}),
    );
  }

  static Future<List<FanClubAppeal>> listFanClubAppeals(
    String artistUid, {
    String status = 'pending',
  }) {
    final path = ApiUrls.withParams(ApiUrls.artistFanclubAppeals, {
      'artistUid': artistUid,
    });
    return HttpService.request(
      '$path?status=${Uri.encodeQueryComponent(status)}',
      parse: (json) {
        final map = (json as Map?)?.cast<String, dynamic>() ?? {};
        return [
          for (final item in map['appeals'] as List? ?? const [])
            FanClubAppeal.fromJson(item as Map<String, dynamic>),
        ];
      },
    );
  }

  static Future<FanClubAppeal> approveFanClubAppeal(
    String artistUid,
    String appealId,
  ) {
    return HttpService.request(
      ApiUrls.withParams(ApiUrls.artistFanclubAppealApprove, {
        'artistUid': artistUid,
        'appealId': appealId,
      }),
      method: Method.post,
      parse: (json) =>
          FanClubAppeal.fromJson(json as Map<String, dynamic>? ?? {}),
    );
  }

  static Future<void> rejectFanClubAppeal(
    String artistUid,
    String appealId, {
    String? reason,
  }) async {
    await HttpService.request<dynamic>(
      ApiUrls.withParams(ApiUrls.artistFanclubAppealReject, {
        'artistUid': artistUid,
        'appealId': appealId,
      }),
      method: Method.post,
      body: {'reason': ?reason},
    );
  }
}
