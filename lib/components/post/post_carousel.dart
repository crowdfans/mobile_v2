import 'package:crowdfans/components/post/post_media_lightbox.dart';
import 'package:flutter/material.dart';

/// Carrossel do feed: o slide mostra um pedaço da próxima imagem.
class PostCarousel extends StatefulWidget {
  const PostCarousel({super.key, required this.uris});

  final List<String> uris;

  @override
  State<PostCarousel> createState() => _PostCarouselState();
}

class _PostCarouselState extends State<PostCarousel> {
  late final PageController _controller;

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
    final slides = _slides;
    if (slides.isEmpty) {
      return const SizedBox.shrink();
    }
    if (slides.length == 1) {
      return GestureDetector(
        onTap: () => PostMediaLightbox.open(context, uris: slides),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            slides.first,
            height: 240,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      );
    }
    return SizedBox(
      height: 240,
      child: PageView.builder(
        controller: _controller,
        padEnds: false,
        itemCount: slides.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: index == slides.length - 1 ? 0 : 8),
            child: GestureDetector(
              onTap: () => PostMediaLightbox.open(
                context,
                uris: slides,
                initialIndex: index,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  slides[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 240,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
