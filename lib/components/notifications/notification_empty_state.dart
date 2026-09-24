import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/notifications_service.dart';
import 'package:flutter/material.dart';

/// Estado vazio específico de cada aba da central de notificações.
class NotificationEmptyState extends StatelessWidget {
  const NotificationEmptyState({super.key, required this.tab});

  final NotificationTab tab;

  static String messageFor(NotificationTab tab) {
    return switch (tab) {
      NotificationTab.all => 'Nenhuma notificação por aqui ainda.',
      NotificationTab.posts => 'Nenhuma notificação de posts nesta aba.',
      NotificationTab.clubs => 'Nenhuma notificação de fã-clubes nesta aba.',
      NotificationTab.meet => 'Nenhum lembrete de Meet & Greet nesta aba.',
      NotificationTab.fanletter => 'Nenhuma notificação de cartas nesta aba.',
      NotificationTab.system => 'Nenhuma notificação do sistema nesta aba.',
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final label = NotificationFilterChipLabels.of(tab);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      child: Column(
        children: [
          Semantics(
            header: true,
            child: Text(
              'Sem novidades em $label',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            messageFor(tab),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: colors.textSecondary),
          ),
        ],
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
