import 'package:flutter/material.dart';

/// Lightbox preto com `Fechar` e indicador `1/3` (print CF-67).
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: widget.uris.length,
              onPageChanged: (index) => setState(() => _index = index),
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  child: Center(
                    child: Image.network(
                      widget.uris[index],
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: handleClose,
                child: const Text(
                  'Fechar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text(
                  '${_index + 1}/${widget.uris.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
