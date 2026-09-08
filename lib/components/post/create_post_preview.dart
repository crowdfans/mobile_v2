import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Preview textual do post antes de publicar.
class CreatePostPreview extends StatelessWidget {
  const CreatePostPreview({
    super.key,
    required this.text,
    required this.hasImage,
  });

  final String text;
  final bool hasImage;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.inputBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.inputBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preview',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: colors.textSecondary,
              ),
            ),
            if (hasImage) ...[
              const SizedBox(height: 8),
              Text(
                '📸 Imagem selecionada',
                style: TextStyle(fontSize: 14, color: colors.textTertiary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
