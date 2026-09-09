import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

class ProfileSettingItem {
  const ProfileSettingItem({required this.label, required this.onTap, this.id});

  final String label;
  final VoidCallback onTap;
  final String? id;
}

/// Bloco de itens no hub de settings.
class ProfileSettingsSection extends StatelessWidget {
  const ProfileSettingsSection({
    super.key,
    required this.title,
    required this.items,
  });

  final String title;
  final List<ProfileSettingItem> items;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: colors.textTertiary,
            ),
          ),
        ),
        for (final item in items)
          ListTile(
            key: item.id == null ? null : Key('settings-item-${item.id}'),
            title: Text(item.label),
            trailing: Icon(Icons.chevron_right, color: colors.icon),
            onTap: item.onTap,
          ),
      ],
    );
  }
}
