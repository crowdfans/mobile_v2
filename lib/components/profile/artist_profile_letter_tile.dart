import 'package:crowdfans/components/fan_letter/fan_letter_background_chip.dart';
import 'package:crowdfans/components/fan_letter/fan_letter_canvas_preview.dart';
import 'package:crowdfans/components/post/post_avatar.dart';
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

  /// Print CF-181: autoria legível sobre capas claras/escuras, sem véu escuro.
  Color authorForeground() {
    final hasImage = (letter.imageUri ?? '').trim().isNotEmpty;
    if (hasImage) {
      return Colors.white;
    }
    final luminance = _preset.color.computeLuminance();
    return luminance > 0.45 ? const Color(0xFF1C1C1E) : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = (letter.imageUri ?? '').trim().isNotEmpty;
    final author = authorLabel();
    final pos = position;
    final fg = authorForeground();
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
              // Só um véu leve em fotos — print das cartas coloridas não usa gradient.
              if (hasImage)
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x66000000),
                        Color(0x00000000),
                      ],
                      stops: [0, 0.28],
                    ),
                  ),
                ),
              Positioned(
                top: 8,
                left: 8,
                right: 8,
                child: Row(
                  children: [
                    PostAvatar(url: letter.fanAvatarUri, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: fg,
                          shadows: hasImage
                              ? const [
                                  Shadow(
                                    blurRadius: 4,
                                    color: Color(0x66000000),
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ),
                    if (pos != null && pos > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: fg.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '#$pos',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: fg,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
