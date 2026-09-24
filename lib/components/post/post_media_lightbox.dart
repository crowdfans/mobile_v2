import 'package:flutter/material.dart';

/// Lightbox preto com Fechar acessível, índice e zoom (ou só pan se reduzir movimento).
class PostMediaLightbox extends StatefulWidget {
  const PostMediaLightbox({
    super.key,
    required this.uris,
    this.initialIndex = 0,
  });

  final List<String> uris;
  final int initialIndex;

  static Future<void> open(
    BuildContext context, {
    required List<String> uris,
    int initialIndex = 0,
  }) {
    final filtered = [
      for (final uri in uris)
        if (uri.trim().isNotEmpty) uri,
    ];
    if (filtered.isEmpty) {
      return Future.value();
    }
    final start = initialIndex.clamp(0, filtered.length - 1);
    return Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        opaque: true,
        barrierColor: Colors.black,
        pageBuilder: (context, animation, secondaryAnimation) {
          return PostMediaLightbox(uris: filtered, initialIndex: start);
        },
      ),
    );
  }

  @override
  State<PostMediaLightbox> createState() => _PostMediaLightboxState();
}

class _PostMediaLightboxState extends State<PostMediaLightbox> {
  late final PageController _controller;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void handleClose() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.uris.length,
            onPageChanged: (index) => setState(() => _index = index),
            itemBuilder: (context, index) {
              final image = Image.network(
                widget.uris[index],
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white54,
                    size: 48,
                  ),
                ),
              );
              return Semantics(
                image: true,
                label: 'Imagem ${index + 1} de ${widget.uris.length}',
                child: Center(
                  child: reduceMotion
                      ? image
                      : InteractiveViewer(
                          minScale: 1,
                          maxScale: 4,
                          child: image,
                        ),
                ),
              );
            },
          ),
          Positioned(
            top: topInset + 4,
            left: 8,
            right: 8,
            child: Row(
              children: [
                const Spacer(),
                Semantics(
                  button: true,
                  label: 'Fechar visualizador',
                  child: TextButton(
                    onPressed: handleClose,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.black.withValues(alpha: 0.45),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                    ),
                    child: const Text(
                      'Fechar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomInset + 20,
            child: Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  child: Text(
                    '${_index + 1}/${widget.uris.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
