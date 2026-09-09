import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

const fanLetterStickerEmojis = ['💌', '⭐', '🎤', '💜', '🔥', '🥹', '✨', '🫶'];

/// Sticker (emoji) inserível no corpo da fan letter.
class FanLetterStickerChip extends StatelessWidget {
  const FanLetterStickerChip({
    super.key,
    required this.emoji,
    required this.onPressed,
  });

  final String emoji;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border),
        ),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 22)),
          ),
        ),
      ),
    );
  }
}
