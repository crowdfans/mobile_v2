import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/notifications_service.dart';
import 'package:flutter/material.dart';

/// Chip de filtro da inbox de notificações.
class NotificationFilterChip extends StatelessWidget {
  const NotificationFilterChip({
    super.key,
    required this.tab,
    required this.selected,
    required this.onPressed,
  });

  final NotificationTab tab;
  final bool selected;
  final VoidCallback onPressed;

  static const labels = {
    NotificationTab.all: 'Todos',
    NotificationTab.posts: 'Posts',
    NotificationTab.clubs: 'Fã Clubes',
    NotificationTab.meet: 'Meet & Greet',
    NotificationTab.fanletter: 'Cartas',
    NotificationTab.system: 'Sistema',
  };

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Material(
      color: selected ? colors.primary : colors.surface,
      shape: StadiumBorder(
        side: BorderSide(color: selected ? colors.primary : colors.border),
      ),
      child: InkWell(
        onTap: onPressed,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Text(
            labels[tab] ?? tab.name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? colors.buttonPrimaryText : colors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
