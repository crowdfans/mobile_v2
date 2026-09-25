import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Aba Novos / Populares com underline do feed do fã clube.
class FanClubSortTab extends StatelessWidget {
  const FanClubSortTab({
    super.key,
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return InkWell(
      onTap: onPressed,
      child: Padding(
        // CF-178: underline IntrinsicWidth = largura do rótulo (print).
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: IntrinsicWidth(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? colors.textPrimary : colors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 3,
                color: selected ? colors.textPrimary : Colors.transparent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
