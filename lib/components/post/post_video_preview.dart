import 'package:crowdfans/components/post/post_media_lightbox.dart';
import 'package:flutter/material.dart';

/// Prévia de vídeo no feed (play + mute + duração), mídia quadrada.
class PostVideoPreview extends StatelessWidget {
  const PostVideoPreview({super.key, this.thumbnailUri, this.duration});

  final String? thumbnailUri;
  final String? duration;

  @override
  Widget build(BuildContext context) {
    final thumb = thumbnailUri?.trim() ?? '';
    final durationLabel =
        (duration ?? '').trim().isEmpty ? '00:00' : duration!.trim();
    return GestureDetector(
      onTap: thumb.isEmpty
          ? null
          : () => PostMediaLightbox.open(context, uris: [thumb]),
      child: AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (thumb.isEmpty)
                const ColoredBox(color: Colors.black)
              else
                Image.network(thumb, fit: BoxFit.cover),
              const Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0x8C000000),
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox(
                    width: 52,
                    height: 52,
                    child: Icon(
                      Icons.play_arrow_rounded,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const Positioned(
                top: 10,
                right: 10,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0x80000000),
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: Icon(
                      Icons.volume_off_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 10,
                bottom: 10,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0x8C000000),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Text(
                      durationLabel,
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
