import 'package:crowdfans/components/post/post_carousel.dart';
import 'package:crowdfans/components/post/post_media_lightbox.dart';
import 'package:crowdfans/components/post/post_video_preview.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:flutter/material.dart';

/// Mídia do card (imagem, carrossel ou vídeo).
class PostMedia extends StatelessWidget {
  const PostMedia({super.key, required this.post});

  final FeedPost post;

  @override
  Widget build(BuildContext context) {
    if (post.type == PostType.video ||
        (post.videoThumbnailUri ?? '').trim().isNotEmpty) {
      return PostVideoPreview(
        thumbnailUri: post.videoThumbnailUri ?? post.imageUri,
        duration: post.videoDuration,
      );
    }
    if (post.carouselUris.length > 1 || post.type == PostType.carousel) {
      final uris = post.carouselUris.isNotEmpty
          ? post.carouselUris
          : [if ((post.imageUri ?? '').trim().isNotEmpty) post.imageUri!];
      return PostCarousel(uris: uris);
    }
    final image = post.imageUri?.trim() ?? '';
    if (image.isEmpty) {
      return const SizedBox.shrink();
    }
    return GestureDetector(
      onTap: () => PostMediaLightbox.open(context, uris: [image]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          image,
          height: 240,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
