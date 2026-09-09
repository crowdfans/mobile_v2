import 'package:flutter/material.dart';

enum SearchRankTrend { up, down, flat }

/// Indicador de tendência do ranking (print Top 500).
class SearchRankTrendDot extends StatelessWidget {
  const SearchRankTrendDot({super.key, required this.trend});

  final SearchRankTrend trend;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (trend) {
      SearchRankTrend.up => (const Color(0xFF22C55E), Icons.arrow_upward_rounded),
      SearchRankTrend.down => (const Color(0xFFEF4444), Icons.arrow_downward_rounded),
      SearchRankTrend.flat => (const Color(0xFF94A3B8), Icons.remove_rounded),
    };
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.5),
      ),
      child: Icon(icon, size: 12, color: color),
    );
  }
}
