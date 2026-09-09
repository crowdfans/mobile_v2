import 'package:crowdfans/components/fan_letter/fan_letter_background_chip.dart';
import 'package:crowdfans/components/fan_letter/fan_letter_canvas_preview.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/fan_letter_service.dart';
import 'package:flutter/material.dart';

/// Card de fan letter na galeria ou no perfil do artista.
class FanLetterCard extends StatelessWidget {
  const FanLetterCard({super.key, required this.letter});

  final FanLetter letter;

  FanLetterBackgroundPreset get _preset {
    return fanLetterBackgroundPresets.firstWhere(
      (item) => item.id == (letter.backgroundId ?? ''),
      orElse: () => fanLetterBackgroundPresets.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final posted = letter.postedAt > 0
        ? DateTime.fromMillisecondsSinceEpoch(letter.postedAt)
        : null;
    final hasImage = (letter.imageUri ?? '').trim().isNotEmpty;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Para ${letter.artistName}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            if (posted != null) ...[
              const SizedBox(height: 4),
              Text(
                '${MaterialLocalizations.of(context).formatFullDate(posted.toLocal())} · ${posted.toLocal().hour.toString().padLeft(2, '0')}:${posted.toLocal().minute.toString().padLeft(2, '0')}',
                style: TextStyle(fontSize: 12, color: colors.textTertiary),
              ),
            ],
            const SizedBox(height: 10),
            AspectRatio(
              aspectRatio: 3 / 4,
              child: hasImage
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.network(
                        letter.imageUri!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return FanLetterCanvasPreview(
                            preset: _preset,
                            bodyText: letter.bodyText ?? '',
                            stickers: const [],
                            strokes: const [],
                            compact: true,
                          );
                        },
                      ),
                    )
                  : FanLetterCanvasPreview(
                      preset: _preset,
                      bodyText: letter.bodyText ?? '',
                      stickers: const [],
                      strokes: const [],
                      compact: true,
                    ),
            ),
            if ((letter.bodyText ?? '').trim().isNotEmpty && hasImage) ...[
              const SizedBox(height: 8),
              Text(
                letter.bodyText!.trim(),
                style: TextStyle(
                  fontSize: 14,
                  height: 20 / 14,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
