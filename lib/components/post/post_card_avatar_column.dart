import 'package:crowdfans/components/post/post_avatar.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:flutter/material.dart';

/// Avatar simples ou stack Reddit (artista + autor) no card do post.
class PostCardAvatarColumn extends StatelessWidget {
  const PostCardAvatarColumn({
    super.key,
    required this.post,
    this.onPressOpenProfile,
  });

  final FeedPost post;
  final VoidCallback? onPressOpenProfile;

  bool get isFanClubLayout =>
      (post.clubArtistName ?? '').trim().isNotEmpty ||
      (post.clubArtistAvatarUri ?? '').trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    if (!isFanClubLayout) {
      return GestureDetector(
        onTap: onPressOpenProfile,
        child: PostAvatar(url: post.avatarUri, size: 44),
      );
    }
    final clubUri = (post.clubArtistAvatarUri ?? post.avatarUri).trim();
    final posterUri = (post.posterAvatarUri ?? post.avatarUri).trim();
    return SizedBox(
      width: 44,
      height: 58,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: onPressOpenProfile,
            child: PostAvatar(url: clubUri, size: 44),
          ),
          if (posterUri.isNotEmpty)
            Positioned(
              left: 8,
              bottom: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.background, width: 2),
                ),
                child: PostAvatar(url: posterUri, size: 28),
              ),
            ),
        ],
      ),
    );
  }
}
