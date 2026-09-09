import 'package:crowdfans/components/profile/notification_preference_row.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/notification_preferences_service.dart';
import 'package:flutter/material.dart';

/// Item de preferência exibido na tela de notificações.
class NotificationPreferenceItem {
  const NotificationPreferenceItem({
    required this.keyName,
    required this.title,
    required this.description,
    this.critical = false,
  });

  final String keyName;
  final String title;
  final String description;
  final bool critical;
}

/// Grupo visual de preferências (título + card).
class NotificationPreferenceGroup {
  const NotificationPreferenceGroup({
    required this.id,
    required this.title,
    required this.items,
  });

  final String id;
  final String title;
  final List<NotificationPreferenceItem> items;
}

/// Catálogo da tela de preferências (espelho do Expo).
const notificationPreferenceGroups = <NotificationPreferenceGroup>[
  NotificationPreferenceGroup(
    id: 'general',
    title: 'Preferências gerais',
    items: [
      NotificationPreferenceItem(
        keyName: NotificationPreferenceKeys.pushEnabled,
        title: 'Notificações push',
        description: 'Receber alertas no celular.',
      ),
      NotificationPreferenceItem(
        keyName: NotificationPreferenceKeys.emailEnabled,
        title: 'Notificações por e-mail',
        description: 'Receber resumos e alertas no e-mail.',
      ),
      NotificationPreferenceItem(
        keyName: NotificationPreferenceKeys.quietModeEnabled,
        title: 'Modo silencioso',
        description: 'Pausa alertas comuns e mantém apenas os críticos.',
      ),
    ],
  ),
  NotificationPreferenceGroup(
    id: 'interactions',
    title: 'Interações com você',
    items: [
      NotificationPreferenceItem(
        keyName: NotificationPreferenceKeys.artistLikeComment,
        title: 'Curtidas em comentários',
        description: 'Quando um artista curtir seu comentário.',
      ),
      NotificationPreferenceItem(
        keyName: NotificationPreferenceKeys.artistLikeFanLetter,
        title: 'Curtidas em Fan Letter',
        description: 'Quando um artista curtir sua carta.',
      ),
      NotificationPreferenceItem(
        keyName: NotificationPreferenceKeys.commentReplies,
        title: 'Respostas',
        description: 'Novas respostas aos seus comentários.',
      ),
      NotificationPreferenceItem(
        keyName: NotificationPreferenceKeys.mentions,
        title: 'Menções',
        description: 'Quando seu perfil for mencionado.',
      ),
      NotificationPreferenceItem(
        keyName: NotificationPreferenceKeys.newFollowers,
        title: 'Novos seguidores',
        description: 'Quando alguém começar a seguir você.',
      ),
    ],
  ),
  NotificationPreferenceGroup(
    id: 'artists',
    title: 'Artistas, cartas e Fã Clubes',
    items: [
      NotificationPreferenceItem(
        keyName: NotificationPreferenceKeys.clubPosts,
        title: 'Posts do Fã Clube',
        description: 'Novas publicações nas comunidades que você acompanha.',
      ),
      NotificationPreferenceItem(
        keyName: NotificationPreferenceKeys.exclusiveContent,
        title: 'Conteúdo exclusivo',
        description: 'Novos conteúdos liberados para membros.',
      ),
      NotificationPreferenceItem(
        keyName: NotificationPreferenceKeys.fanLetterReceived,
        title: 'Fan Letters',
        description: 'Atualizações sobre cartas enviadas.',
      ),
      NotificationPreferenceItem(
        keyName: NotificationPreferenceKeys.artistHighlights,
        title: 'Destaques do artista',
        description: 'Novidades importantes dos seus artistas.',
      ),
    ],
  ),
  NotificationPreferenceGroup(
    id: 'meet',
    title: 'Meet & Greet',
    items: [
      NotificationPreferenceItem(
        keyName: NotificationPreferenceKeys.meetInvites,
        title: 'Convites',
        description: 'Convites para participar de Meet & Greet.',
        critical: true,
      ),
      NotificationPreferenceItem(
        keyName: NotificationPreferenceKeys.meetReminders,
        title: 'Lembretes',
        description: 'Fila, horário e início da chamada.',
        critical: true,
      ),
      NotificationPreferenceItem(
        keyName: NotificationPreferenceKeys.meetResults,
        title: 'Encerramento',
        description: 'Resultado e gravação quando disponível.',
      ),
    ],
  ),
  NotificationPreferenceGroup(
    id: 'wallet',
    title: 'Membership e Jam Coins',
    items: [
      NotificationPreferenceItem(
        keyName: NotificationPreferenceKeys.membershipRenewals,
        title: 'Renovações',
        description: 'Cobranças, falhas e saldo insuficiente.',
        critical: true,
      ),
      NotificationPreferenceItem(
        keyName: NotificationPreferenceKeys.jamCoinsBalance,
        title: 'Saldo de Jam Coins',
        description: 'Movimentações e alertas de saldo.',
        critical: true,
      ),
      NotificationPreferenceItem(
        keyName: NotificationPreferenceKeys.jamCoinsPromos,
        title: 'Promoções',
        description: 'Campanhas e ofertas de Jam Coins.',
      ),
    ],
  ),
];

/// Card de uma seção de preferências.
class NotificationPreferenceSection extends StatelessWidget {
  const NotificationPreferenceSection({
    super.key,
    required this.group,
    required this.preferences,
    required this.saving,
    required this.onChanged,
  });

  final NotificationPreferenceGroup group;
  final NotificationPreferences preferences;
  final bool saving;
  final void Function(String key, bool value) onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final quiet =
        preferences[NotificationPreferenceKeys.quietModeEnabled] == true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          group.title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: colors.textTertiary,
          ),
        ),
        const SizedBox(height: 8),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: [
              for (var i = 0; i < group.items.length; i++)
                NotificationPreferenceRow(
                  title: group.items[i].title,
                  description: group.items[i].description,
                  value: preferences[group.items[i].keyName] ?? false,
                  enabled:
                      !(saving ||
                          (quiet &&
                              !group.items[i].critical &&
                              group.items[i].keyName !=
                                  NotificationPreferenceKeys.quietModeEnabled)),
                  showDivider: i > 0,
                  onChanged: (value) =>
                      onChanged(group.items[i].keyName, value),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
