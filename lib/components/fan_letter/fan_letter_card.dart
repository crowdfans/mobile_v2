import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/fan_letter_service.dart';
import 'package:flutter/material.dart';

/// Card de fan letter na galeria ou no perfil do artista.
class FanLetterCard extends StatelessWidget {
  const FanLetterCard({super.key, required this.letter});

  final FanLetter letter;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final posted = letter.postedAt > 0
        ? DateTime.fromMillisecondsSinceEpoch(letter.postedAt)
        : null;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
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
                posted.toLocal().toString().split('.').first,
                style: TextStyle(fontSize: 12, color: colors.textTertiary),
              ),
            ],
            if ((letter.bodyText ?? '').trim().isNotEmpty) ...[
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
            if ((letter.imageUri ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  letter.imageUri!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
