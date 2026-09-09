import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Abas de produto dos Insights (Tudo / Posts / Fã clube / …).
class AnalyticsContentTabs extends StatelessWidget {
  const AnalyticsContentTabs({
    super.key,
    required this.tabs,
    required this.selectedId,
    required this.onSelected,
  });

  final List<(String, String)> tabs;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final item in tabs)
            Padding(
              padding: const EdgeInsets.only(right: 18),
              child: GestureDetector(
                onTap: () => onSelected(item.$1),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.$2,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: selectedId == item.$1
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: selectedId == item.$1
                            ? colors.textPrimary
                            : colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 2,
                      width: item.$2.length * 7.2,
                      color: selectedId == item.$1
                          ? colors.textPrimary
                          : Colors.transparent,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
