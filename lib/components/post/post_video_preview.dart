import 'package:crowdfans/components/post/post_media_lightbox.dart';
import 'package:flutter/material.dart';

/// Prévia de vídeo no feed (play + duração). Autoplay entra depois.
class PostVideoPreview extends StatelessWidget {
  const PostVideoPreview({super.key, this.thumbnailUri, this.duration});

  final String? thumbnailUri;
  final String? duration;

  @override
  Widget build(BuildContext context) {
    final thumb = thumbnailUri?.trim() ?? '';
    return GestureDetector(
      onTap: thumb.isEmpty
          ? null
          : () => PostMediaLightbox.open(context, uris: [thumb]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 240,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (thumb.isEmpty)
                const ColoredBox(color: Colors.black)
              else
                Image.network(thumb, fit: BoxFit.cover),
              const ColoredBox(color: Color(0x33000000)),
              const Center(
                child: Icon(
                  Icons.play_circle_fill,
                  size: 64,
                  color: Colors.white,
                ),
              ),
              if (duration != null && duration!.trim().isNotEmpty)
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xCC000000),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Text(
                        duration!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
