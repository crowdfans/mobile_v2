import 'package:crowdfans/components/fan_letter/fan_letter_sticker_catalog.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Sheet "Adesivos" do mock Superfã (coleções → stickers).
class FanLetterStickersSheet extends StatefulWidget {
  const FanLetterStickersSheet({
    super.key,
    required this.onClose,
    required this.onPickAsset,
  });

  final VoidCallback onClose;
  final ValueChanged<String> onPickAsset;

  /// Abre o sheet e devolve o path do asset escolhido.
  static Future<String?> present(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final colors = CrowdFansTheme.of(context);
        return DraggableScrollableSheet(
          initialChildSize: 0.72,
          minChildSize: 0.45,
          maxChildSize: 0.92,
          builder: (context, controller) {
            return Material(
              color: colors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: FanLetterStickersSheet(
                onClose: () => Navigator.pop(context),
                onPickAsset: (asset) => Navigator.pop(context, asset),
              ),
            );
          },
        );
      },
    );
  }

  @override
  State<FanLetterStickersSheet> createState() => _FanLetterStickersSheetState();
}

class _FanLetterStickersSheetState extends State<FanLetterStickersSheet> {
  FanLetterStickerCollection? _opened;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final opened = _opened;
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
                if (opened != null)
                  IconButton(
                    onPressed: () => setState(() => _opened = null),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        opened?.title ?? 'Adesivos',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        opened?.description ??
                            'Escolha uma coleção e depois navegue só pelos stickers daquele universo.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 18 / 13,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: widget.onClose,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Expanded(
            child: opened == null
                ? ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                    itemCount: fanLetterStickerCollections.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final collection = fanLetterStickerCollections[index];
                      final previews = collection.assets.take(3).toList();
                      return Material(
                        color: colors.surfaceAlt,
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => setState(() => _opened = collection),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    for (final asset in previews) ...[
                                      DecoratedBox(
                                        decoration: BoxDecoration(
                                          color: colors.surface,
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Image.asset(
                                            asset,
                                            width: 56,
                                            height: 56,
                                            fit: BoxFit.contain,
                                            errorBuilder: (_, _, _) => Icon(
                                              Icons.sticky_note_2_outlined,
                                              color: colors.textTertiary,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  collection.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: colors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  collection.description,
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 18 / 13,
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1,
                        ),
                    itemCount: opened.assets.length,
                    itemBuilder: (context, index) {
                      final asset = opened.assets[index];
                      return Material(
                        color: colors.surfaceAlt,
                        borderRadius: BorderRadius.circular(18),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => widget.onPickAsset(asset),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Image.asset(
                              asset,
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => Icon(
                                Icons.sticky_note_2_outlined,
                                color: colors.textTertiary,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
