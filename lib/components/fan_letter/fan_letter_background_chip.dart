import 'package:flutter/material.dart';

/// Tipo visual do fundo da Fan Letter.
enum FanLetterBackgroundKind { solid, gradient, pattern }

/// Fundo pré-definido da fan letter.
class FanLetterBackgroundPreset {
  const FanLetterBackgroundPreset({
    required this.id,
    required this.label,
    required this.kind,
    required this.colors,
    this.category = 'Cores sólidas',
    this.pattern,
  });

  final String id;
  final String label;
  final FanLetterBackgroundKind kind;
  final List<Color> colors;
  final String category;
  final FanLetterPatternStyle? pattern;

  Color get color => colors.first;
}

enum FanLetterPatternStyle { dots, grid, stars }

/// Presets alinhados ao mock (gradientes, sólidas e patterns).
const fanLetterBackgroundPresets = [
  FanLetterBackgroundPreset(
    id: 'grad-lilac',
    label: 'Lilás',
    kind: FanLetterBackgroundKind.gradient,
    category: 'Gradientes',
    colors: [Color(0xFFE8DEFF), Color(0xFFF8E8FF)],
  ),
  FanLetterBackgroundPreset(
    id: 'grad-sky',
    label: 'Céu',
    kind: FanLetterBackgroundKind.gradient,
    category: 'Gradientes',
    colors: [Color(0xFFD7E8F7), Color(0xFFF5FBFF)],
  ),
  FanLetterBackgroundPreset(
    id: 'grad-mint',
    label: 'Menta',
    kind: FanLetterBackgroundKind.gradient,
    category: 'Gradientes',
    colors: [Color(0xFFD9F2E6), Color(0xFFF4FFF9)],
  ),
  FanLetterBackgroundPreset(
    id: 'grad-peach',
    label: 'Pêssego',
    kind: FanLetterBackgroundKind.gradient,
    category: 'Gradientes',
    colors: [Color(0xFFFFE3C8), Color(0xFFFFF7EF)],
  ),
  FanLetterBackgroundPreset(
    id: 'paper-cream',
    label: 'Creme',
    kind: FanLetterBackgroundKind.solid,
    category: 'Cores sólidas',
    colors: [Color(0xFFF4EFE6)],
  ),
  FanLetterBackgroundPreset(
    id: 'solid-butter',
    label: 'Manteiga',
    kind: FanLetterBackgroundKind.solid,
    category: 'Cores sólidas',
    colors: [Color(0xFFFFF3B0)],
  ),
  FanLetterBackgroundPreset(
    id: 'mint',
    label: 'Menta',
    kind: FanLetterBackgroundKind.solid,
    category: 'Cores sólidas',
    colors: [Color(0xFFD9F2E6)],
  ),
  FanLetterBackgroundPreset(
    id: 'blush',
    label: 'Blush',
    kind: FanLetterBackgroundKind.solid,
    category: 'Cores sólidas',
    colors: [Color(0xFFF7D9E3)],
  ),
  FanLetterBackgroundPreset(
    id: 'sky-soft',
    label: 'Céu',
    kind: FanLetterBackgroundKind.solid,
    category: 'Cores sólidas',
    colors: [Color(0xFFD7E8F7)],
  ),
  FanLetterBackgroundPreset(
    id: 'night',
    label: 'Noite',
    kind: FanLetterBackgroundKind.solid,
    category: 'Cores sólidas',
    colors: [Color(0xFF1F2430)],
  ),
  FanLetterBackgroundPreset(
    id: 'pattern-dots',
    label: 'Pontos',
    kind: FanLetterBackgroundKind.pattern,
    category: 'Patterns',
    colors: [Color(0xFFE8F8E4)],
    pattern: FanLetterPatternStyle.dots,
  ),
  FanLetterBackgroundPreset(
    id: 'pattern-grid',
    label: 'Grade',
    kind: FanLetterBackgroundKind.pattern,
    category: 'Patterns',
    colors: [Color(0xFFFFE8D4)],
    pattern: FanLetterPatternStyle.grid,
  ),
  FanLetterBackgroundPreset(
    id: 'pattern-stars',
    label: 'Estrelas',
    kind: FanLetterBackgroundKind.pattern,
    category: 'Patterns',
    colors: [Color(0xFFFFF4C8)],
    pattern: FanLetterPatternStyle.stars,
  ),
];

/// Decora o fundo da carta conforme o preset.
class FanLetterBackgroundFill extends StatelessWidget {
  const FanLetterBackgroundFill({super.key, required this.preset});

  final FanLetterBackgroundPreset preset;

  @override
  Widget build(BuildContext context) {
    switch (preset.kind) {
      case FanLetterBackgroundKind.gradient:
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: preset.colors.length >= 2
                  ? preset.colors
                  : [preset.color, preset.color],
            ),
          ),
          child: const SizedBox.expand(),
        );
      case FanLetterBackgroundKind.pattern:
        return CustomPaint(
          painter: _PatternPainter(
            base: preset.color,
            style: preset.pattern ?? FanLetterPatternStyle.dots,
          ),
          child: const SizedBox.expand(),
        );
      case FanLetterBackgroundKind.solid:
        return ColoredBox(color: preset.color, child: const SizedBox.expand());
    }
  }
}

class _PatternPainter extends CustomPainter {
  const _PatternPainter({required this.base, required this.style});

  final Color base;
  final FanLetterPatternStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = base);
    final ink = Paint()
      ..color = const Color(0x33000000)
      ..style = PaintingStyle.fill;
    switch (style) {
      case FanLetterPatternStyle.dots:
        for (var y = 12.0; y < size.height; y += 22) {
          for (var x = 12.0; x < size.width; x += 22) {
            canvas.drawCircle(Offset(x, y), 2.2, ink);
          }
        }
      case FanLetterPatternStyle.grid:
        final stroke = Paint()
          ..color = const Color(0x22000000)
          ..strokeWidth = 1;
        for (var x = 0.0; x < size.width; x += 18) {
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), stroke);
        }
        for (var y = 0.0; y < size.height; y += 18) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), stroke);
        }
      case FanLetterPatternStyle.stars:
        final text = TextPainter(
          text: const TextSpan(
            text: '✦',
            style: TextStyle(fontSize: 12, color: Color(0x33000000)),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        for (var y = 10.0; y < size.height; y += 28) {
          for (var x = 10.0; x < size.width; x += 28) {
            text.paint(canvas, Offset(x, y));
          }
        }
    }
  }

  @override
  bool shouldRepaint(covariant _PatternPainter oldDelegate) {
    return oldDelegate.base != base || oldDelegate.style != style;
  }
}

/// Swatch de fundo no compose / sheet.
class FanLetterBackgroundChip extends StatelessWidget {
  const FanLetterBackgroundChip({
    super.key,
    required this.preset,
    required this.selected,
    required this.onPressed,
    this.size = 72,
  });

  final FanLetterBackgroundPreset preset;
  final bool selected;
  final VoidCallback onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : const Color(0xFFCBD5E1),
            width: selected ? 2.5 : 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            width: size,
            height: size,
            child: FanLetterBackgroundFill(preset: preset),
          ),
        ),
      ),
    );
  }
}
