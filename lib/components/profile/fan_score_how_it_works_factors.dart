import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Bloco “O que entra na conta” sob os cards explicativos (CF-202 / print).
class FanScoreHowItWorksFactors extends StatelessWidget {
  const FanScoreHowItWorksFactors({super.key, required this.body});

  /// Texto do print (ou fixture TEMP) listando o que conta no ciclo.
  final String body;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'O que entra na conta',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              body,
              style: TextStyle(
                fontSize: 14,
                height: 20 / 14,
                color: colors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
