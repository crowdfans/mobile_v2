import 'package:crowdfans/components/post/post_media_lightbox.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Carrossel do feed: proporção 1:1, clipping e pista da próxima foto.
class PostCarousel extends StatefulWidget {
  const PostCarousel({super.key, required this.uris});

  final List<String> uris;

  @override
  State<PostCarousel> createState() => _PostCarouselState();
}

class _PostCarouselState extends State<PostCarousel> {
  late final PageController _controller;
  var _index = 0;

  List<String> get _slides => [
    for (final uri in widget.uris)
      if (uri.trim().isNotEmpty) uri,
  ];

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.92);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final slides = _slides;
    if (slides.isEmpty) {
      return const SizedBox.shrink();
    }
    if (slides.length == 1) {
      return Semantics(
        image: true,
        label: 'Imagem 1 de 1',
        child: GestureDetector(
          onTap: () => PostMediaLightbox.open(context, uris: slides),
          child: AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                slides.first,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => ColoredBox(color: colors.surfaceAlt),
              ),
            ),
          ),
        ),
      );
    }
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            // Horizontal page gestos não precisam bloquear scroll vertical do feed.
            onNotification: (_) => false,
            child: PageView.builder(
              controller: _controller,
              padEnds: false,
              itemCount: slides.length,
              onPageChanged: (index) => setState(() => _index = index),
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: index == slides.length - 1 ? 0 : 6,
                  ),
                  child: Semantics(
                    image: true,
                    label: 'Imagem ${index + 1} de ${slides.length}',
                    child: GestureDetector(
                      onTap: () => PostMediaLightbox.open(
                        context,
                        uris: slides,
                        initialIndex: index,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          slides[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (_, _, _) =>
                              ColoredBox(color: colors.surfaceAlt),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            right: 10,
            top: 10,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Text(
                  '${_index + 1}/${slides.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < slides.length; i++)
                  Container(
                    width: i == _index ? 8 : 6,
                    height: i == _index ? 8 : 6,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == _index
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.45),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
