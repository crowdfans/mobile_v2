import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Chips de período (7 / 30 / 90 dias) no estilo dos prints Artista.
class AnalyticsPeriodChips extends StatelessWidget {
  const AnalyticsPeriodChips({
    super.key,
    required this.periods,
    required this.selectedId,
    required this.onSelected,
  });

  final List<(String, String)> periods;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final item in periods)
          GestureDetector(
            onTap: () => onSelected(item.$1),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: selectedId == item.$1
                    ? colors.textPrimary
                    : colors.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: selectedId == item.$1
                      ? colors.textPrimary
                      : colors.border,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                child: Text(
                  item.$2,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selectedId == item.$1
                        ? colors.background
                        : colors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
