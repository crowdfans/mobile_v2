import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/notifications_service.dart';
import 'package:flutter/material.dart';

/// Estado vazio da central de notificações (CF-190).
///
/// Print: uma única linha centrada — sem título “Sem novidades…”.
class NotificationEmptyState extends StatelessWidget {
  const NotificationEmptyState({super.key, required this.tab});

  final NotificationTab tab;

  static const emptyMessage = 'Nenhuma notificação nesta aba ainda.';

  static String messageFor(NotificationTab tab) => emptyMessage;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
      child: Center(
        child: Text(
          emptyMessage,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: colors.textSecondary),
        ),
      ),
    );
  }
}

/// Rótulos das abas (compartilhados com o chip).
abstract final class NotificationFilterChipLabels {
  static const map = {
    NotificationTab.all: 'Todos',
    NotificationTab.posts: 'Posts',
    NotificationTab.clubs: 'Fã Clubes',
    NotificationTab.meet: 'Meet & Greet',
    NotificationTab.fanletter: 'Cartas',
    NotificationTab.system: 'Sistema',
  };

  static String of(NotificationTab tab) => map[tab] ?? tab.name;
}
