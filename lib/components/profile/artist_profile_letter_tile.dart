import 'package:crowdfans/components/fan_letter/fan_letter_background_chip.dart';
import 'package:crowdfans/components/fan_letter/fan_letter_canvas_preview.dart';
import 'package:crowdfans/services/fan_letter_service.dart';
import 'package:flutter/material.dart';

/// Tile compacto da grade de cartas no perfil público do artista.
class ArtistProfileLetterTile extends StatelessWidget {
  const ArtistProfileLetterTile({super.key, required this.letter});

  final FanLetter letter;

  FanLetterBackgroundPreset get _preset {
    return fanLetterBackgroundPresets.firstWhere(
      (item) => item.id == (letter.backgroundId ?? ''),
      orElse: () => fanLetterBackgroundPresets.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = (letter.imageUri ?? '').trim().isNotEmpty;
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: hasImage
            ? Image.network(
                letter.imageUri!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) {
                  return FanLetterCanvasPreview(
                    preset: _preset,
                    bodyText: letter.bodyText ?? '',
                    stickers: const [],
                    strokes: const [],
                    compact: true,
                  );
                },
              )
            : FanLetterCanvasPreview(
                preset: _preset,
                bodyText: letter.bodyText ?? '',
                stickers: const [],
                strokes: const [],
                compact: true,
              ),
      ),
    );
  }
}
