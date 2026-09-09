import 'package:crowdfans/api/api_urls.dart';
import 'package:crowdfans/services/http_service.dart';

/// Fan letter enviada a um artista.
class FanLetter {
  const FanLetter({
    required this.id,
    required this.artistId,
    required this.artistName,
    required this.fanDisplayName,
    required this.fanHandle,
    required this.fanAvatarUri,
    required this.votesCount,
    required this.sendsCount,
    required this.artistUpvoted,
    required this.postedAt,
    this.artistAvatarUri,
    this.imageUri,
    this.bodyText,
    this.backgroundId,
  });

  final String id;
  final String artistId;
  final String artistName;
  final String? artistAvatarUri;
  final String fanDisplayName;
  final String fanHandle;
  final String fanAvatarUri;
  final String? imageUri;
  final String? bodyText;
  final String? backgroundId;
  final int votesCount;
  final int sendsCount;
  final bool artistUpvoted;
  final int postedAt;

  factory FanLetter.fromJson(Object? json) {
    final map = (json as Map?)?.cast<String, dynamic>() ?? {};
    return FanLetter(
      id: map['id']?.toString() ?? '',
      artistId: map['artistId']?.toString() ?? '',
      artistName: map['artistName']?.toString() ?? '',
      artistAvatarUri: map['artistAvatarUri'] as String?,
      fanDisplayName: map['fanDisplayName']?.toString() ?? '',
      fanHandle: map['fanHandle']?.toString() ?? '',
      fanAvatarUri: map['fanAvatarUri']?.toString() ?? '',
      imageUri: map['imageUri'] as String?,
      bodyText: map['bodyText'] as String?,
      backgroundId: map['backgroundId'] as String?,
      votesCount: (map['votesCount'] as num?)?.toInt() ?? 0,
      sendsCount: (map['sendsCount'] as num?)?.toInt() ?? 0,
      artistUpvoted: map['artistUpvoted'] == true,
      postedAt: (map['postedAt'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Cota grátis e custo em Jam Coins.
class FanLetterMonetization {
  const FanLetterMonetization({
    required this.isMember,
    required this.freeLettersUsed,
    required this.freeLettersLimit,
    required this.jamCoinsBalance,
    required this.jamCoinsCost,
  });

  final bool isMember;
  final int freeLettersUsed;
  final int freeLettersLimit;
  final int jamCoinsBalance;
  final int jamCoinsCost;

  factory FanLetterMonetization.fromJson(Object? json) {
    final map = (json as Map?)?.cast<String, dynamic>() ?? {};
    return FanLetterMonetization(
      isMember: map['isMember'] == true,
      freeLettersUsed: (map['freeLettersUsed'] as num?)?.toInt() ?? 0,
      freeLettersLimit: (map['freeLettersLimit'] as num?)?.toInt() ?? 0,
      jamCoinsBalance: (map['jamCoinsBalance'] as num?)?.toInt() ?? 0,
      jamCoinsCost: (map['jamCoinsCost'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Payload de criação de fan letter.
class CreateFanLetterRequest {
  const CreateFanLetterRequest({
    required this.artistId,
    required this.artistName,
    this.artistAvatarUri,
    this.bodyText,
    this.imageUri,
    this.backgroundId,
  });

  final String artistId;
  final String artistName;
  final String? artistAvatarUri;
  final String? bodyText;
  final String? imageUri;
  final String? backgroundId;

  Map<String, Object?> toJson() {
    return {
      'artistId': artistId,
      'artistName': artistName,
      if (artistAvatarUri != null) 'artistAvatarUri': artistAvatarUri,
      if (bodyText != null) 'bodyText': bodyText,
      if (imageUri != null) 'imageUri': imageUri,
      if (backgroundId != null) 'backgroundId': backgroundId,
    };
  }
}

/// Fan letters (`/api/v1/fan-letters`).
abstract final class FanLetterService {
  static Future<List<FanLetter>> listMyFanLetters() async {
    final data = await HttpService.request<Map<String, dynamic>>(
      ApiUrls.fanLettersMine,
      parse: (json) => (json as Map?)?.cast<String, dynamic>() ?? {},
    );
    return [
      for (final item in data['letters'] as List? ?? const [])
        FanLetter.fromJson(item),
    ];
  }

  static Future<List<FanLetter>> listArtistFanLetters(String artistId) async {
    final data = await HttpService.request<Map<String, dynamic>>(
      ApiUrls.withParams(ApiUrls.fanLettersArtist, {'artistId': artistId}),
      parse: (json) => (json as Map?)?.cast<String, dynamic>() ?? {},
    );
    return [
      for (final item in data['letters'] as List? ?? const [])
        FanLetter.fromJson(item),
    ];
  }

  static Future<FanLetterMonetization> getMonetization(String artistId) {
    return HttpService.request(
      '${ApiUrls.fanLettersMonetization}?artistId=${Uri.encodeQueryComponent(artistId)}',
      parse: FanLetterMonetization.fromJson,
    );
  }

  static Future<FanLetter> createFanLetter(CreateFanLetterRequest payload) {
    return HttpService.request(
      ApiUrls.fanLetters,
      method: Method.post,
      body: payload.toJson(),
      parse: FanLetter.fromJson,
    );
  }
}
