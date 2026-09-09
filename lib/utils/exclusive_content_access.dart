import 'package:crowdfans/models/feed_post.dart';

/// Contexto do viewer para decidir acesso a conteúdo exclusivo.
class ExclusiveAccessContext {
  const ExclusiveAccessContext({
    this.subscribedArtistUids = const {},
    this.subscribedArtistNames = const {},
    this.viewerDisplayName,
    this.viewerUserUid,
    this.viewerIsArtist = false,
  });

  final Set<String> subscribedArtistUids;
  final Set<String> subscribedArtistNames;
  final String? viewerDisplayName;
  final String? viewerUserUid;
  final bool viewerIsArtist;
}

String normalizeExclusiveIdentity(String? value) {
  if (value == null) {
    return '';
  }
  return value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'^@'), '')
      .replaceAll(RegExp(r'^artist/'), '')
      .replaceAll(RegExp(r'[^a-z0-9]+'), '');
}

bool isExclusivePost(FeedPost post) {
  return post.isExclusive ||
      post.exclusiveLocked ||
      post.membershipLocked ||
      post.type == PostType.membership;
}

bool hasUnlockedMembershipStatus(String? status) {
  final normalized = status?.trim().toLowerCase();
  return normalized == 'active' ||
      normalized == 'renews-soon' ||
      normalized == 'ativa';
}

bool canAccessExclusivePost(FeedPost post, ExclusiveAccessContext context) {
  if (!isExclusivePost(post)) {
    return true;
  }
  if (post.exclusiveLocked == false && post.membershipLocked != true) {
    return true;
  }
  final artistId = post.artistId?.trim() ?? '';
  final viewerUid = context.viewerUserUid?.trim() ?? '';
  if (context.viewerIsArtist &&
      viewerUid.isNotEmpty &&
      artistId.isNotEmpty &&
      artistId == viewerUid) {
    return true;
  }
  final authorKey = normalizeExclusiveIdentity(post.author);
  final handleKey = normalizeExclusiveIdentity(post.handle);
  if (context.viewerIsArtist && (context.viewerDisplayName ?? '').isNotEmpty) {
    final viewerKey = normalizeExclusiveIdentity(context.viewerDisplayName);
    if ((authorKey.isNotEmpty && authorKey == viewerKey) ||
        (handleKey.isNotEmpty && handleKey == viewerKey)) {
      return true;
    }
  }
  if (authorKey.isNotEmpty &&
      context.subscribedArtistNames.contains(authorKey)) {
    return true;
  }
  if (handleKey.isNotEmpty &&
      context.subscribedArtistNames.contains(handleKey)) {
    return true;
  }
  if (artistId.isNotEmpty && context.subscribedArtistUids.contains(artistId)) {
    return true;
  }
  return false;
}
