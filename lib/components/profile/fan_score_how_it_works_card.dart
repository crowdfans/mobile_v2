import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

enum FanScoreHowItWorksCardTone { purple, neutral, benefit, scoring }

/// Card explicativo da tela "Como funciona o FanScore" (CF-202).
class FanScoreHowItWorksCard extends StatelessWidget {
  const FanScoreHowItWorksCard({
    super.key,
    required this.title,
    required this.body,
    this.tone = FanScoreHowItWorksCardTone.neutral,
    this.eyebrow,
    this.footer,
  });

  final String title;
  final String body;
  final FanScoreHowItWorksCardTone tone;
  final String? eyebrow;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final (Color bg, Color border, Color titleColor, Color bodyColor) =
        switch (tone) {
          FanScoreHowItWorksCardTone.purple => (
            AppPalette.purple50,
            AppPalette.purple200,
            colors.textPrimary,
            colors.textPrimary,
          ),
          FanScoreHowItWorksCardTone.benefit => (
            AppPalette.orange50,
            AppPalette.orange300,
            colors.textPrimary,
            colors.textPrimary,
          ),
          FanScoreHowItWorksCardTone.scoring => (
            colors.surface,
            AppPalette.orange200,
            colors.textPrimary,
            colors.textSecondary,
          ),
          FanScoreHowItWorksCardTone.neutral => (
            colors.surface,
            colors.border,
            colors.textPrimary,
            colors.textSecondary,
          ),
        };

    return Semantics(
      header: true,
      label: [
        if ((eyebrow ?? '').trim().isNotEmpty) eyebrow!.trim(),
        title,
        body,
        if ((footer ?? '').trim().isNotEmpty) footer!.trim(),
      ].join('. '),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if ((eyebrow ?? '').trim().isNotEmpty) ...[
                Text(
                  eyebrow!.trim().toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                    color: AppPalette.orange700,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                body,
                style: TextStyle(
                  fontSize: 14,
                  height: 20 / 14,
                  color: bodyColor,
                ),
              ),
              if ((footer ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  footer!.trim(),
                  style: const TextStyle(
                    fontSize: 13,
                    height: 18 / 13,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.purple700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
