import 'package:flutter/material.dart';

/// Lightbox preto com Fechar acessível, índice e zoom (ou só pan se reduzir movimento).
///
/// Print CF-234: fundo preto, **Fechar** no topo direito (área segura),
/// indicador `n/m` no rodapé central — texto branco sem pill, mídia com
/// [BoxFit.contain] (sem esticar).
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

  static const _controlShadow = [
    Shadow(color: Colors.black87, blurRadius: 10, offset: Offset(0, 1)),
  ];

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
            top: topInset + 8,
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
                      backgroundColor: Colors.transparent,
                      minimumSize: const Size(48, 44),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Fechar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        shadows: _controlShadow,
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
            bottom: bottomInset + 24,
            child: Center(
              child: Semantics(
                liveRegion: true,
                label: 'Imagem ${_index + 1} de ${widget.uris.length}',
                child: Text(
                  '${_index + 1}/${widget.uris.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    shadows: _controlShadow,
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
