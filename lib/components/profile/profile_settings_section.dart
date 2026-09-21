import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileSettingItem {
  const ProfileSettingItem({
    required this.label,
    required this.onTap,
    required this.asset,
    this.id,
    this.showChevron = true,
    this.danger = false,
  });

  final String label;
  final VoidCallback onTap;
  final String asset;
  final String? id;
  final bool showChevron;
  final bool danger;
}

/// Bloco de itens no hub de settings (prints CF-108).
class ProfileSettingsSection extends StatelessWidget {
  const ProfileSettingsSection({
    super.key,
    required this.title,
    required this.items,
    this.showDivider = true,
  });

  final String title;
  final List<ProfileSettingItem> items;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ColoredBox(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.textTertiary,
                ),
              ),
            ),
          ),
        ),
        for (var index = 0; index < items.length; index++) ...[
          InkWell(
            key: items[index].id == null
                ? null
                : Key('settings-item-${items[index].id}'),
            onTap: items[index].onTap,
            child: SizedBox(
              height: 60,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      items[index].asset,
                      width: 22,
                      height: 22,
                      colorFilter: ColorFilter.mode(
                        items[index].danger ? colors.danger : colors.icon,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        items[index].label,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: items[index].danger
                              ? colors.danger
                              : colors.textPrimary,
                        ),
                      ),
                    ),
                    if (items[index].showChevron) const SizedBox(width: 25),
                    if (items[index].showChevron)
                      SvgPicture.asset(
                        'assets/icons/arrows/chevron-right.svg',
                        width: 18,
                        height: 18,
                        colorFilter: ColorFilter.mode(
                          colors.textTertiary,
                          BlendMode.srcIn,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (index < items.length - 1) const SizedBox(height: 8),
        ],
        if (showDivider)
          ColoredBox(
            color: colors.surfaceAlt,
            child: const SizedBox(
              width: double.infinity,
              height: 8,
            ),
          ),
      ],
    );
  }
}
