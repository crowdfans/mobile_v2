/// Detalhamento das atividades que compõem o Fan Score.
class FanScoreBreakdown {
  const FanScoreBreakdown({
    this.hasMembership = false,
    this.commentsMade = 0,
    this.upvotesMade = 0,
    this.fanLettersPosted = 0,
    this.liveDonations = 0,
    this.liveParticipations = 0,
    this.fanClubPosts = 0,
  });

  final bool hasMembership;
  final int commentsMade;
  final int upvotesMade;
  final int fanLettersPosted;
  final int liveDonations;
  final int liveParticipations;
  final int fanClubPosts;

  factory FanScoreBreakdown.fromJson(Object? json) {
    final map = (json as Map?)?.cast<String, dynamic>() ?? {};
    return FanScoreBreakdown(
      hasMembership: map['hasMembership'] == true,
      commentsMade: (map['commentsMade'] as num?)?.toInt() ?? 0,
      upvotesMade: (map['upvotesMade'] as num?)?.toInt() ?? 0,
      fanLettersPosted: (map['fanLettersPosted'] as num?)?.toInt() ?? 0,
      liveDonations: (map['liveDonations'] as num?)?.toInt() ?? 0,
      liveParticipations: (map['liveParticipations'] as num?)?.toInt() ?? 0,
      fanClubPosts: (map['fanClubPosts'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Nível visual do Fan Score para um artista.
class FanScoreTier {
  const FanScoreTier({
    required this.id,
    required this.label,
    this.minScore = 0,
    this.badgeGradient = const [],
    this.gradient = const [],
    this.accentColor = '',
    this.badgeText = '',
    this.border = '',
  });

  final String id;
  final String label;
  final int minScore;
  final List<String> badgeGradient;
  final List<String> gradient;
  final String accentColor;
  final String badgeText;
  final String border;

  factory FanScoreTier.fromJson(Object? json) {
    final map = (json as Map?)?.cast<String, dynamic>() ?? {};
    return FanScoreTier(
      id: map['id']?.toString() ?? '',
      label: map['label']?.toString() ?? '',
      minScore: (map['minScore'] as num?)?.toInt() ?? 0,
      badgeGradient: _stringList(map['badgeGradient']),
      gradient: _stringList(map['gradient']),
      accentColor: map['accentColor']?.toString() ?? '',
      badgeText: map['badgeText']?.toString() ?? '',
      border: map['border']?.toString() ?? map['borderColor']?.toString() ?? '',
    );
  }
}

/// Pontuação do fã para um artista.
class FanScoreEntry {
  const FanScoreEntry({
    required this.artistId,
    required this.artistName,
    required this.artistAvatarUri,
    required this.memberCount,
    required this.currentScore,
    required this.deltaPercentage,
    required this.breakdown,
    required this.tier,
    this.fanRank,
  });

  final String artistId;
  final String artistName;
  final String artistAvatarUri;
  final String memberCount;
  final int currentScore;
  final int deltaPercentage;
  final int? fanRank;
  final FanScoreBreakdown breakdown;
  final FanScoreTier tier;

  factory FanScoreEntry.fromJson(Object? json) {
    final map = (json as Map?)?.cast<String, dynamic>() ?? {};
    return FanScoreEntry(
      artistId: map['artistId']?.toString() ?? '',
      artistName: map['artistName']?.toString() ?? '',
      artistAvatarUri: map['artistAvatarUri']?.toString() ?? '',
      memberCount: map['memberCount']?.toString() ?? '0',
      currentScore: (map['currentScore'] as num?)?.toInt() ?? 0,
      deltaPercentage: (map['deltaPercentage'] as num?)?.toInt() ?? 0,
      fanRank: (map['fanRank'] as num?)?.toInt(),
      breakdown: FanScoreBreakdown.fromJson(map['breakdown']),
      tier: FanScoreTier.fromJson(map['tier']),
    );
  }
}

/// Período de apuração do Fan Score.
class FanScoreCycleDetails {
  const FanScoreCycleDetails({
    this.cycleLabel,
    this.endLabel,
    this.helperText,
    this.periodLabel,
  });

  final String? cycleLabel;
  final String? endLabel;
  final String? helperText;
  final String? periodLabel;

  factory FanScoreCycleDetails.fromJson(Object? json) {
    final map = (json as Map?)?.cast<String, dynamic>() ?? {};
    return FanScoreCycleDetails(
      cycleLabel: map['cycleLabel'] as String?,
      endLabel: map['endLabel'] as String?,
      helperText: map['helperText'] as String?,
      periodLabel: map['periodLabel'] as String?,
    );
  }
}

/// Resposta de `GET /api/v1/profiles/:handle/fan-score`.
class FanScoreData {
  const FanScoreData({this.entries = const [], this.cycleDetails});

  final List<FanScoreEntry> entries;
  final FanScoreCycleDetails? cycleDetails;

  factory FanScoreData.fromJson(Object? json) {
    final map = (json as Map?)?.cast<String, dynamic>() ?? {};
    final cycle = map['cycleDetails'];
    return FanScoreData(
      entries: [
        for (final item in map['entries'] as List? ?? const [])
          FanScoreEntry.fromJson(item),
      ],
      cycleDetails: cycle == null ? null : FanScoreCycleDetails.fromJson(cycle),
    );
  }
}

List<String> _stringList(Object? json) {
  return [for (final item in json as List? ?? const []) item.toString()];
}
