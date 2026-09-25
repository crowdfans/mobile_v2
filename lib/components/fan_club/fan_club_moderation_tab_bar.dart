import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Abas Contestações / Avisos / Expulsos do painel de moderação.
class FanClubModerationTabBar extends StatelessWidget {
  const FanClubModerationTabBar({
    super.key,
    required this.selectedId,
    required this.contestationCount,
    required this.warningCount,
    required this.expulsionCount,
    required this.onSelected,
  });

  final String selectedId;
  final int contestationCount;
  final int warningCount;
  final int expulsionCount;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final tabs = <(String, String, int)>[
      ('contestacoes', 'Contestações', contestationCount),
      ('avisos', 'Avisos', warningCount),
      ('expulsos', 'Expulsos', expulsionCount),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            _ModerationTabPill(
              label: '${tabs[i].$2} ${tabs[i].$3}',
              selected: selectedId == tabs[i].$1,
              onPressed: () => onSelected(tabs[i].$1),
              colors: colors,
            ),
          ],
        ],
      ),
    );
  }
}

class _ModerationTabPill extends StatelessWidget {
  const _ModerationTabPill({
    required this.label,
    required this.selected,
    required this.onPressed,
    required this.colors,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: selected ? colors.primary : colors.surface,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? colors.primary : colors.border,
          ),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected
                    ? colors.buttonPrimaryText
                    : colors.textTertiary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
