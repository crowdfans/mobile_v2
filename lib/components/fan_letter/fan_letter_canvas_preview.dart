import 'package:crowdfans/components/fan_letter/fan_letter_background_chip.dart';
import 'package:flutter/material.dart';

/// Sticker posicionado na carta.
class FanLetterPlacedSticker {
  const FanLetterPlacedSticker({
    required this.id,
    required this.asset,
    required this.offset,
  });

  final String id;
  final String asset;
  final Offset offset;

  FanLetterPlacedSticker copyWith({Offset? offset}) {
    return FanLetterPlacedSticker(
      id: id,
      asset: asset,
      offset: offset ?? this.offset,
    );
  }
}

/// Traço livre no canvas.
class FanLetterStroke {
  const FanLetterStroke({
    required this.points,
    required this.color,
    required this.width,
  });

  final List<Offset> points;
  final Color color;
  final double width;
}

/// Canvas visual da carta (fundo + texto + stickers + traços).
class FanLetterCanvasPreview extends StatelessWidget {
  const FanLetterCanvasPreview({
    super.key,
    required this.preset,
    required this.bodyText,
    required this.stickers,
    required this.strokes,
    this.compact = false,
    this.onStickerMoved,
  });

  final FanLetterBackgroundPreset preset;
  final String bodyText;
  final List<FanLetterPlacedSticker> stickers;
  final List<FanLetterStroke> strokes;
  final bool compact;
  final void Function(String id, Offset offset)? onStickerMoved;

  Color get _textColor =>
      preset.id == 'night' ? const Color(0xFFF5F5F5) : const Color(0xFF1A1A1A);

  @override
  Widget build(BuildContext context) {
    final radius = compact ? 18.0 : 36.0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          FanLetterBackgroundFill(preset: preset),
          CustomPaint(painter: _StrokesPainter(strokes: strokes)),
          if (bodyText.trim().isNotEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 10 : 24,
                  vertical: compact ? 12 : 28,
                ),
                child: Text(
                  bodyText.trim(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: compact ? 12 : 22,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    color: _textColor,
                  ),
                ),
              ),
            ),
          for (final sticker in stickers)
            Positioned(
              left: sticker.offset.dx,
              top: sticker.offset.dy,
              child: GestureDetector(
                onPanUpdate: onStickerMoved == null
                    ? null
                    : (details) {
                        onStickerMoved!(
                          sticker.id,
                          sticker.offset + details.delta,
                        );
                      },
                child: Image.asset(
                  sticker.asset,
                  width: compact ? 36 : 84,
                  height: compact ? 36 : 84,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StrokesPainter extends CustomPainter {
  const _StrokesPainter({required this.strokes});

  final List<FanLetterStroke> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      if (stroke.points.length < 2) {
        continue;
      }
      final path = Path()..moveTo(stroke.points.first.dx, stroke.points.first.dy);
      for (final point in stroke.points.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = stroke.color
          ..strokeWidth = stroke.width
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StrokesPainter oldDelegate) {
    return oldDelegate.strokes != strokes;
  }
}
