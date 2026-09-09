import 'package:flutter/material.dart';

/// Fundo pré-definido da fan letter.
class FanLetterBackgroundPreset {
  const FanLetterBackgroundPreset({
    required this.id,
    required this.label,
    required this.color,
  });

  final String id;
  final String label;
  final Color color;
}

const fanLetterBackgroundPresets = [
  FanLetterBackgroundPreset(
    id: 'paper-cream',
    label: 'Creme',
    color: Color(0xFFF4EFE6),
  ),
  FanLetterBackgroundPreset(
    id: 'sky-soft',
    label: 'Céu',
    color: Color(0xFFD7E8F7),
  ),
  FanLetterBackgroundPreset(
    id: 'blush',
    label: 'Blush',
    color: Color(0xFFF7D9E3),
  ),
  FanLetterBackgroundPreset(
    id: 'mint',
    label: 'Menta',
    color: Color(0xFFD9F2E6),
  ),
  FanLetterBackgroundPreset(
    id: 'night',
    label: 'Noite',
    color: Color(0xFF1F2430),
  ),
  FanLetterBackgroundPreset(
    id: 'sunset',
    label: 'Pôr do sol',
    color: Color(0xFFF7C9A8),
  ),
];

/// Swatch de fundo no compose da fan letter.
class FanLetterBackgroundChip extends StatelessWidget {
  const FanLetterBackgroundChip({
    super.key,
    required this.preset,
    required this.selected,
    required this.onPressed,
  });

  final FanLetterBackgroundPreset preset;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: preset.color,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : const Color(0xFFCBD5E1),
            width: 2,
          ),
        ),
        child: const SizedBox(width: 36, height: 36),
      ),
    );
  }
}
