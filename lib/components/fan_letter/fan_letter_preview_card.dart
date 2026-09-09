import 'package:crowdfans/components/fan_letter/fan_letter_background_chip.dart';
import 'package:crowdfans/components/fan_letter/fan_letter_canvas_preview.dart';
import 'package:flutter/material.dart';

/// Preview compacto da carta no compose / diálogos.
class FanLetterPreviewCard extends StatelessWidget {
  const FanLetterPreviewCard({
    super.key,
    required this.preset,
    required this.bodyText,
  });

  final FanLetterBackgroundPreset preset;
  final String bodyText;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: FanLetterCanvasPreview(
        preset: preset,
        bodyText: bodyText,
        stickers: const [],
        strokes: const [],
        compact: true,
      ),
    );
  }
}
