import 'package:crowdfans/components/fan_letter/fan_letter_background_chip.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Sheet "Planos de fundo" do mock Superfã.
class FanLetterBackgroundsSheet extends StatelessWidget {
  const FanLetterBackgroundsSheet({
    super.key,
    required this.selectedId,
    required this.onClose,
    required this.onSelect,
  });

  final String selectedId;
  final VoidCallback onClose;
  final ValueChanged<String> onSelect;

  static Future<String?> present(
    BuildContext context, {
    required String selectedId,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final colors = CrowdFansTheme.of(context);
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.45,
          maxChildSize: 0.92,
          builder: (context, controller) {
            return Material(
              color: colors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: FanLetterBackgroundsSheet(
                selectedId: selectedId,
                onClose: () => Navigator.pop(context),
                onSelect: (id) => Navigator.pop(context, id),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final categories = <String, List<FanLetterBackgroundPreset>>{};
    for (final preset in fanLetterBackgroundPresets) {
      categories.putIfAbsent(preset.category, () => []).add(preset);
    }
    return SafeArea(
      top: false,
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.border,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Planos de fundo',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Escolha entre gradientes, cores sólidas e patterns para montar a carta.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 18 / 13,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(onPressed: onClose, icon: const Icon(Icons.close)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                for (final entry in categories.entries) ...[
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.surfaceAlt,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            entry.key == 'Gradientes'
                                ? 'Do mais claro ao mais intenso para escolher o clima da carta.'
                                : entry.key == 'Cores sólidas'
                                ? 'Tons organizados dos mais suaves aos mais fechados.'
                                : 'Texturas leves para cartas com personalidade.',
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 78,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: entry.value.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(width: 10),
                              itemBuilder: (context, index) {
                                final preset = entry.value[index];
                                return FanLetterBackgroundChip(
                                  preset: preset,
                                  selected: preset.id == selectedId,
                                  onPressed: () => onSelect(preset.id),
                                  size: 78,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
