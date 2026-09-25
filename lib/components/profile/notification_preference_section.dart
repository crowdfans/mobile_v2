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
    this.pageIntro,
  });

  final String id;
  final String title;
  final List<NotificationPreferenceItem> items;
  /// Resumo exibido no hub de categorias (CF-166); null = só na página geral.
  final String? navSubtitle;
  /// Texto introdutório da subpágina (CF-208 / CF-209 / CF-211).
  final String? pageIntro;
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
    title: 'Interações com Você',
    navSubtitle:
        'Curtidas do artista nas suas coisas, respostas, menções ao seu fan/ e novos seguidores.',
    pageIntro:
        'Escolha quais interações pessoais merecem um alerta imediato, principalmente quando vierem do próprio artista.',
    items: [
      NotificationPreferenceItem(
        keyName: NotificationPreferenceKeys.artistLikeComment,
        title: 'Artista curtiu seu comentário',
        description:
            'Quando o próprio artista curtir especificamente um comentário seu.',
      ),
      NotificationPreferenceItem(
        keyName: NotificationPreferenceKeys.artistLikeFanLetter,
        title: 'Artista curtiu sua carta',
        description:
            'Quando o artista der upvote ou destaque na sua Carta de Fã.',
      ),
      NotificationPreferenceItem(
        keyName: NotificationPreferenceKeys.commentReplies,
        title: 'Respostas aos seus comentários',
        description:
            'Quando responderem um comentário seu em posts e fã clubes.',
      ),
      NotificationPreferenceItem(
        keyName: NotificationPreferenceKeys.mentions,
        title: 'Menções ao seu fan/',
        description:
            'Quando alguém mencionar o seu fan/ em comentários, posts ou cartas.',
      ),
      NotificationPreferenceItem(
        keyName: NotificationPreferenceKeys.newFollowers,
        title: 'Novos seguidores',
        description: 'Quando novos fãs começarem a seguir você.',
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
    pageIntro:
        'Controle desde convites e lembretes de fila até os avisos de encerramento das chamadas.',
    items: [
      NotificationPreferenceItem(
        keyName: NotificationPreferenceKeys.meetInvites,
        title: 'Convites para Meet & Greet',
        description:
            'Quando você for selecionado ou convocado para uma chamada.',
        critical: true,
      ),
      NotificationPreferenceItem(
        keyName: NotificationPreferenceKeys.meetReminders,
        title: 'Lembretes de Meet & Greet',
        description:
            'Avisos antes da chamada, entrada na fila e início da sua vez.',
        critical: true,
      ),
      NotificationPreferenceItem(
        keyName: NotificationPreferenceKeys.meetResults,
        title: 'Resultado e encerramento',
        description:
            'Quando o Meet terminar ou quando a janela de acesso mudar.',
      ),
    ],
  ),
  NotificationPreferenceGroup(
    id: 'wallet',
    title: 'Membership e Jam Coins',
    navSubtitle:
        'Renovação, saldo insuficiente, recargas, promoções e pagamentos.',
    pageIntro:
        'Ajuste tudo que envolve cobrança, saldo, promoções e alertas ligados ao seu membership.',
    items: [
      NotificationPreferenceItem(
        keyName: NotificationPreferenceKeys.membershipRenewals,
        title: 'Renovação de membership',
        description:
            'Cobrança próxima, saldo insuficiente, renovação confirmada e cancelamento.',
        critical: true,
      ),
      NotificationPreferenceItem(
        keyName: NotificationPreferenceKeys.jamCoinsPromos,
        title: 'Promoções de Jam Coins',
        description:
            'Campanhas, bônus de recarga e ofertas especiais de Jam Coins.',
      ),
      NotificationPreferenceItem(
        keyName: NotificationPreferenceKeys.jamCoinsBalance,
        title: 'Saldo e pagamentos',
        description:
            'Recargas aprovadas, saldo baixo e pagamentos concluídos.',
        critical: true,
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

/// Seção de preferências sem contorno externo (CF-166): título + linhas.
class NotificationPreferenceSection extends StatelessWidget {
  const NotificationPreferenceSection({
    super.key,
    required this.group,
    required this.preferences,
    required this.saving,
    required this.onChanged,
    this.showTitle = true,
  });

  final NotificationPreferenceGroup group;
  final NotificationPreferences preferences;
  final bool saving;
  final void Function(String key, bool value) onChanged;
  /// Na subpágina o título já está no header (prints CF-208+).
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final quiet =
        preferences[NotificationPreferenceKeys.quietModeEnabled] == true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle) ...[
          Text(
            group.title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: colors.textTertiary,
            ),
          ),
          const SizedBox(height: 8),
        ],
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
            onChanged: (value) => onChanged(group.items[i].keyName, value),
          ),
      ],
    );
  }
}
