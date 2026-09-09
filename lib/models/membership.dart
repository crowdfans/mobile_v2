/// Cartão de membership retornado por `GET /api/v1/profiles/:handle/memberships`.
class MembershipCard {
  const MembershipCard({
    required this.id,
    this.artistId,
    this.artistName,
    this.artistAvatarUri,
    this.label,
    this.status,
    this.statusLabel,
    this.monthlyPrice,
    this.pricePerMonth,
    this.monthsLabel,
    this.renewalLabel,
    this.availabilityLabel,
    this.isCurrentMember = false,
  });

  final String id;
  final String? artistId;
  final String? artistName;
  final String? artistAvatarUri;
  final String? label;
  final String? status;
  final String? statusLabel;
  final num? monthlyPrice;
  final num? pricePerMonth;
  final String? monthsLabel;
  final String? renewalLabel;
  final String? availabilityLabel;
  final bool isCurrentMember;

  String get displayName {
    final name = artistName?.trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }
    final fallback = label?.trim();
    if (fallback != null && fallback.isNotEmpty) {
      return fallback;
    }
    return 'Artista';
  }

  num? get price => monthlyPrice ?? pricePerMonth;

  String get normalizedStatus => (status ?? '').trim().toLowerCase();

  bool get isCancelled => normalizedStatus == 'cancelled';

  bool get isLate =>
      normalizedStatus == 'late' || normalizedStatus == 'past_due';

  bool get isActiveStatus => !isCancelled && !isLate;

  bool get canCancel {
    final id = artistId?.trim() ?? '';
    return id.isNotEmpty && !isCancelled;
  }

  factory MembershipCard.fromJson(Object? json) {
    final map = (json as Map?)?.cast<String, dynamic>() ?? {};
    return MembershipCard(
      id:
          map['id']?.toString() ??
          map['artistId']?.toString() ??
          map['artistUid']?.toString() ??
          '',
      artistId: map['artistId'] as String? ?? map['artistUid'] as String?,
      artistName: map['artistName'] as String? ?? map['label'] as String?,
      artistAvatarUri:
          map['artistAvatarUri'] as String? ?? map['avatarUrl'] as String?,
      label: map['label'] as String?,
      status: map['status'] as String?,
      statusLabel: map['statusLabel'] as String?,
      monthlyPrice: map['monthlyPrice'] as num?,
      pricePerMonth: map['pricePerMonth'] as num?,
      monthsLabel: map['monthsLabel'] as String?,
      renewalLabel: map['renewalLabel'] as String?,
      availabilityLabel: map['availabilityLabel'] as String?,
      isCurrentMember: map['isCurrentMember'] == true,
    );
  }
}

/// Visão de memberships ativas + catálogo.
class MembershipOverview {
  const MembershipOverview({
    this.jamCoinsBalance = '0',
    this.cards = const [],
    this.catalog = const [],
  });

  final String jamCoinsBalance;
  final List<MembershipCard> cards;
  final List<MembershipCard> catalog;

  MembershipOverview copyWith({
    String? jamCoinsBalance,
    List<MembershipCard>? cards,
    List<MembershipCard>? catalog,
  }) {
    return MembershipOverview(
      jamCoinsBalance: jamCoinsBalance ?? this.jamCoinsBalance,
      cards: cards ?? this.cards,
      catalog: catalog ?? this.catalog,
    );
  }

  factory MembershipOverview.fromJson(Object? json) {
    final map = (json as Map?)?.cast<String, dynamic>() ?? {};
    return MembershipOverview(
      jamCoinsBalance:
          map['jamCoinsBalance']?.toString() ??
          map['balance']?.toString() ??
          '0',
      cards: [
        for (final item in map['cards'] as List? ?? const [])
          MembershipCard.fromJson(item),
      ],
      catalog: [
        for (final item in map['catalog'] as List? ?? const [])
          MembershipCard.fromJson(item),
      ],
    );
  }
}
