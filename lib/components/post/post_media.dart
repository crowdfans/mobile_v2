import 'package:crowdfans/components/post/post_carousel.dart';
import 'package:crowdfans/components/post/post_media_lightbox.dart';
import 'package:crowdfans/components/post/post_video_preview.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:flutter/material.dart';

/// Mídia do card (imagem, carrossel, vídeo ou membership) — quadrada no PDF.
class PostMedia extends StatelessWidget {
  const PostMedia({super.key, required this.post});

  final FeedPost post;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    if (post.type == PostType.membership) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Container(
          height: 136,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: const LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [AppPalette.purple900, AppPalette.blue700],
            ),
          ),
          alignment: Alignment.center,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppPalette.yellow600, width: 1.2),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.music_note,
                    size: 13,
                    color: AppPalette.orange500,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    (post.membershipTitle ?? '').trim().isEmpty
                        ? 'Membership'
                        : post.membershipTitle!,
                    style: const TextStyle(
                      color: AppPalette.orange600,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    if (post.type == PostType.video ||
        (post.videoThumbnailUri ?? '').trim().isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: PostVideoPreview(
          thumbnailUri: post.videoThumbnailUri ?? post.imageUri,
          duration: post.videoDuration,
        ),
      );
    }
    if (post.carouselUris.length > 1 || post.type == PostType.carousel) {
      final uris = post.carouselUris.isNotEmpty
          ? post.carouselUris
          : [if ((post.imageUri ?? '').trim().isNotEmpty) post.imageUri!];
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: PostCarousel(uris: uris),
      );
    }
    final image = post.imageUri?.trim() ?? '';
    if (image.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: GestureDetector(
        onTap: () => PostMediaLightbox.open(context, uris: [image]),
        child: AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(image, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}
