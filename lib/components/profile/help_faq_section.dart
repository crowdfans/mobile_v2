import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Pergunta e resposta já abertas (sem accordion).
class HelpFaqItem extends StatelessWidget {
  const HelpFaqItem({
    super.key,
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  question,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                answer,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.55,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, thickness: 1, color: colors.border),
      ],
    );
  }
}

/// Seção temática da Central de ajuda.
class HelpFaqSection extends StatelessWidget {
  const HelpFaqSection({
    super.key,
    required this.title,
    required this.items,
  });

  final String title;
  final List<(String, String)> items;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: colors.textTertiary,
            ),
          ),
        ),
        const SizedBox(height: 14),
        for (final item in items)
          HelpFaqItem(question: item.$1, answer: item.$2),
      ],
    );
  }
}
