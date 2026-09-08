import 'package:crowdfans/models/feed_post.dart';

bool isExclusivePost(FeedPost post) {
  return post.isExclusive || post.type == PostType.membership;
}

bool canAccessExclusivePost(FeedPost post, {required bool viewerIsArtist}) {
  if (!isExclusivePost(post)) {
    return true;
  }
  if (viewerIsArtist) {
    return true;
  }
  return post.exclusiveLocked == false;
}
