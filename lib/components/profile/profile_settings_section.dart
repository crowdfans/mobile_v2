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
          color: colors.surfaceAlt,
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
        for (final item in items)
          InkWell(
            key: item.id == null ? null : Key('settings-item-${item.id}'),
            onTap: item.onTap,
            child: SizedBox(
              height: 52,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      item.asset,
                      width: 22,
                      height: 22,
                      colorFilter: ColorFilter.mode(
                        item.danger ? colors.danger : colors.icon,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: item.danger
                              ? colors.danger
                              : colors.textPrimary,
                        ),
                      ),
                    ),
                    if (item.showChevron)
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
        if (showDivider) const SizedBox(height: 4),
      ],
    );
  }
}
