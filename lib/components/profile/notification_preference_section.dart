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

/// Grupo visual de preferências (título + itens).
class NotificationPreferenceGroup {
  const NotificationPreferenceGroup({
    required this.id,
    required this.title,
    required this.items,
    this.navSubtitle,
  });

  final String id;
  final String title;
  final List<NotificationPreferenceItem> items;
  /// Resumo exibido no hub de categorias (CF-166); null = só na página geral.
  final String? navSubtitle;
}

/// Catálogo da tela de preferências (espelho do Expo + hub CF-166).
const notificationPreferenceGroups = <NotificationPreferenceGroup>[
  NotificationPreferenceGroup(
    id: 'general',
    title: 'Preferências Gerais',
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
    navSubtitle:
        'Curtidas do artista, respostas, menções e novos seguidores.',
    items: [
      NotificationPreferenceItem(
        keyName: NotificationPreferenceKeys.artistLikeComment,
        title: 'Curtida do artista no comentário',
        description: 'Quando um artista curtir seu comentário.',
      ),
      NotificationPreferenceItem(
        keyName: NotificationPreferenceKeys.artistLikeFanLetter,
        title: 'Curtida do artista na carta',
        description: 'Quando um artista curtir sua Fan Letter.',
      ),
      NotificationPreferenceItem(
        keyName: NotificationPreferenceKeys.commentReplies,
        title: 'Respostas',
        description: 'Novas respostas aos seus comentários.',
      ),
      NotificationPreferenceItem(
        keyName: NotificationPreferenceKeys.mentions,
        title: 'Menções',
        description: 'Quando mencionarem seu perfil (fan/).',
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
    title: 'Artistas, Cartas e Fã Clubes',
    navSubtitle:
        'Posts, cartas, destaques do artista, conteúdo exclusivo e controle por artista.',
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
    navSubtitle:
        'Convites, lembretes de fila, início da chamada e encerramento.',
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
    navSubtitle:
        'Renovação, saldo insuficiente, recargas, promoções e pagamentos.',
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

/// Grupos detalhados navegáveis a partir do hub (CF-166).
List<NotificationPreferenceGroup> get notificationCategoryGroups =>
    notificationPreferenceGroups
        .where((group) => group.navSubtitle != null)
        .toList(growable: false);

NotificationPreferenceGroup? notificationGroupById(String id) {
  for (final group in notificationPreferenceGroups) {
    if (group.id == id) {
      return group;
    }
  }
  return null;
}

/// Seção de preferências (CF-166): título + card com linhas internas.
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
            borderRadius: BorderRadius.circular(14),
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
