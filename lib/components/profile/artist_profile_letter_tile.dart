import 'package:crowdfans/components/fan_letter/fan_letter_background_chip.dart';
import 'package:crowdfans/components/fan_letter/fan_letter_canvas_preview.dart';
import 'package:crowdfans/services/fan_letter_service.dart';
import 'package:flutter/material.dart';

/// Tile compacto da grade de cartas no perfil público do artista.
class ArtistProfileLetterTile extends StatelessWidget {
  const ArtistProfileLetterTile({
    super.key,
    required this.letter,
    this.position,
  });

  final FanLetter letter;
  final int? position;

  FanLetterBackgroundPreset get _preset {
    return fanLetterBackgroundPresets.firstWhere(
      (item) => item.id == (letter.backgroundId ?? ''),
      orElse: () => fanLetterBackgroundPresets.first,
    );
  }

  String authorLabel() {
    final name = letter.fanDisplayName.trim();
    if (name.isNotEmpty) {
      return name;
    }
    final handle = letter.fanHandle.trim().replaceAll(RegExp(r'^@'), '');
    return handle.isEmpty ? 'Fã' : handle;
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = (letter.imageUri ?? '').trim().isNotEmpty;
    final author = authorLabel();
    final pos = position;
    return Semantics(
      label: [
        if (pos != null && pos > 0) 'Carta $pos',
        'de $author',
      ].join(' '),
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              hasImage
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
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x66000000),
                      Color(0x00000000),
                      Color(0x99000000),
                    ],
                    stops: [0, 0.45, 1],
                  ),
                ),
              ),
              if (pos != null && pos > 0)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '#$pos',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: Text(
                  author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
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
