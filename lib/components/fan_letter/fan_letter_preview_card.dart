import 'package:crowdfans/components/fan_letter/fan_letter_background_chip.dart';
import 'package:flutter/material.dart';

/// Preview da carta no compose.
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
    final textColor = preset.id == 'night'
        ? const Color(0xFFF5F5F5)
        : const Color(0xFF1A1A1A);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: preset.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preview · ${preset.label}',
              style: TextStyle(fontSize: 12, color: textColor.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 8),
            Text(
              bodyText.trim().isEmpty
                  ? 'Sua mensagem aparece aqui...'
                  : bodyText.trim(),
              style: TextStyle(fontSize: 15, height: 22 / 15, color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}
