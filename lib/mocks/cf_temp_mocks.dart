// TEMP MOCKS — delete this file when APIs are ready
//
// Arquivo único de mocks temporários (QA / demo).
// CF-190: central de notificações (print image.png).
// CF-193/189/200+: ranking, expulsão, membership — seções abaixo.
// Outros CFs: acrescentar aqui — não criar outros arquivos em lib/mocks/.
//
// Desligar CF-190: `kUseCf190NotificationMocks = false`
// Forçar vazio: `kCf190MockEmpty = true`
// Remover: apague este arquivo e os imports/`if` nos services que o usam.

import 'package:crowdfans/services/notifications_service.dart';
import 'package:crowdfans/services/search_service.dart';

/// Master: qualquer mock deste arquivo. Preferir flags por feature abaixo.
const bool kUseCfTempMocks = true;

/// CF-190 — inbox povoada (Agora / Hoje) igual ao print.
const bool kUseCf190NotificationMocks = true;

/// CF-190 — lista vazia para validar empty state do print.
const bool kCf190MockEmpty = false;

/// Mocks temporários CrowdFans (um arquivo só).
abstract final class CfTempMocks {
  // --- Feature flags (backlog UX) ---

  /// Ranking Top 100 Engajados / Top 500 (CF-193, CF-189).
  static const useRankingFixtures = true;

  /// FanScore insights / how-it-works demos (CF-201, CF-202).
  static const useFanScoreFixtures = true;

  /// Membership / recarga confirmação (CF-204…207).
  static const useMembershipFixtures = true;

  /// Preferências de notificação povoadas (CF-213).
  static const useNotificationPrefFixtures = true;

  /// Fã-clube perfil / moderadores / regras / expulsão (CF-200, CF-222…230).
  static const useFanClubFixtures = true;

  /// Artistas favoritos no menu lateral (CF-191).
  static const useFavoriteArtistsFixtures = true;

  // --- CF-190 avatars / thumbs ---
  static const _avatarWoman =
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=100&q=80';
  static const _avatarMayra =
      'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=100&q=80';
  static const _avatarMeet =
      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=100&q=80';
  static const _avatarRed =
      'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=100&q=80';
  static const _avatarMan =
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=100&q=80';
  static const _avatarCamila =
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=100&q=80';
  static const _rockHand = 'assets/images/rock-hand.png';
  static const _thumbFeed =
      'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?auto=format&fit=crop&w=200&q=80';
  static const _thumbMic =
      'https://images.unsplash.com/photo-1516280440612-596598c2f5a2?auto=format&fit=crop&w=200&q=80';

  /// CF-190: seções Agora / Hoje do print de referência.
  static List<NotificationSection> notificationSections() {
    if (kCf190MockEmpty) {
      return const [];
    }
    return const [
      NotificationSection(
        id: 'now',
        title: 'Agora',
        items: [
          NotificationItem(
            id: 'cf190-ban',
            category: 'clubs',
            time: '21h',
            unread: true,
            avatarUris: [_avatarWoman],
            content: [
              NotificationSegment(text: 'Você foi banido', accent: true),
              NotificationSegment(text: ' do fã clube de '),
              NotificationSegment(text: 'Ravi Tavares', accent: true),
              NotificationSegment(
                text: '. Toque para contestar sua saída.',
              ),
            ],
            targetRoute: '/fan-clubs/defend-return',
          ),
          NotificationItem(
            id: 'cf190-warning',
            category: 'clubs',
            time: '42m',
            unread: true,
            avatarUris: [_avatarWoman],
            content: [
              NotificationSegment(text: 'Você recebeu um aviso', accent: true),
              NotificationSegment(text: ' no fã clube de '),
              NotificationSegment(text: 'Laís Costa', accent: true),
              NotificationSegment(text: '. Restam 2 chances.'),
            ],
            targetRoute: '/me/settings/moderation',
          ),
        ],
      ),
      NotificationSection(
        id: 'today',
        title: 'Hoje',
        items: [
          NotificationItem(
            id: 'cf190-like-comment',
            category: 'posts',
            time: '5m',
            unread: true,
            avatarUris: [_avatarMayra, _avatarRed],
            thumbnailUri: _thumbFeed,
            content: [
              NotificationSegment(text: 'Mayra', accent: true),
              NotificationSegment(
                text: ' curtiu especificamente o seu comentário no feed dela',
              ),
            ],
            targetRoute: '/feed',
          ),
          NotificationItem(
            id: 'cf190-meet',
            category: 'meet',
            time: '9m',
            unread: true,
            avatarUris: [_avatarMeet],
            content: [
              NotificationSegment(
                text: 'Lembrete de Meet & Greet:',
                accent: true,
              ),
              NotificationSegment(text: ' sua chamada com '),
              NotificationSegment(text: 'Laís Costa', accent: true),
              NotificationSegment(text: ' começa em 15 minutos'),
            ],
            targetRoute: '/meet',
          ),
          NotificationItem(
            id: 'cf190-fanletter-upvote',
            category: 'fanletter',
            time: '12m',
            avatarUris: [_avatarRed],
            thumbnailUri: _thumbMic,
            content: [
              NotificationSegment(text: 'Mayra', accent: true),
              NotificationSegment(
                text:
                    ' deu upvote na sua Carta de Fã e ela foi para os destaques',
              ),
            ],
            targetRoute: '/fan-letter/gallery',
          ),
          NotificationItem(
            id: 'cf190-club-join',
            category: 'clubs',
            time: '24m',
            avatarUris: [_avatarMan, _avatarCamila],
            thumbnailUri: _thumbFeed,
            content: [
              NotificationSegment(text: 'camilasanchez', accent: true),
              NotificationSegment(text: ', '),
              NotificationSegment(text: 'muca', accent: true),
              NotificationSegment(text: ' entraram no fã clube de '),
              NotificationSegment(text: 'Mayra', accent: true),
            ],
            targetRoute: '/clubs',
          ),
          NotificationItem(
            id: 'cf190-membership-renew',
            category: 'system',
            time: '48m',
            avatarUris: [_rockHand],
            content: [
              NotificationSegment(
                text: 'Seu membership em Marinhos',
                accent: true,
              ),
              NotificationSegment(
                text:
                    ' renova amanhã às 10:00. Garanta saldo suficiente em Jam Coins.',
              ),
            ],
            targetRoute: '/me/settings/wallet',
          ),
          NotificationItem(
            id: 'cf190-membership-open',
            category: 'system',
            time: '5h',
            avatarUris: [_rockHand],
            content: [
              NotificationSegment(
                text: 'Mayra abriu novo membership',
                accent: true,
              ),
              NotificationSegment(
                text: ' com conteúdo exclusivo e acesso antecipado.',
              ),
            ],
            targetRoute: '/feed',
          ),
        ],
      ),
    ];
  }
}

/// Linhas de ranking para demo quando `rankArtists` vem vazio (CF-193 / CF-189).
List<ArtistSearchItem> cfTempMockRankingArtists({
  required String kind,
  int limit = 8,
}) {
  final engaged = kind == 'engaged';
  final active = kind == 'active';
  final samples = <ArtistSearchItem>[
    ArtistSearchItem(
      id: 'mock-rank-1',
      name: 'Gus Art',
      handle: '@gusart',
      avatarUri: '',
      memberCount: engaged ? 4 : 512000,
      membersLabel: engaged ? '4 interações (7d)' : '512 mil membros',
      rankingValueLabel: engaged
          ? '4 interações (7d)'
          : (active ? '18 posts (7d)' : '512 mil membros'),
      rank: 1,
      trend: 'neutral',
      rankDelta: 0,
      previousRank: 1,
      weeksInRanking: 12,
      peakRank: 1,
    ),
    ArtistSearchItem(
      id: 'mock-rank-2',
      name: 'Mayra Art',
      handle: '@mayraart',
      avatarUri: '',
      memberCount: engaged ? 0 : 420000,
      membersLabel: engaged ? '0 interações (7d)' : '420 mil membros',
      rankingValueLabel: engaged
          ? '0 interações (7d)'
          : (active ? '14 posts (7d)' : '420 mil membros'),
      rank: 2,
      trend: 'up',
      rankDelta: 2,
      previousRank: 4,
      weeksInRanking: 8,
      peakRank: 2,
    ),
    ArtistSearchItem(
      id: 'mock-rank-3',
      name: 'Luna Beat',
      handle: '@lunabeat',
      avatarUri: '',
      memberCount: engaged ? 12 : 318000,
      membersLabel: engaged ? '12 interações (7d)' : '318 mil membros',
      rankingValueLabel: engaged
          ? '12 interações (7d)'
          : (active ? '11 posts (7d)' : '318 mil membros'),
      rank: 3,
      trend: 'down',
      rankDelta: 1,
      previousRank: 2,
      weeksInRanking: 5,
      peakRank: 1,
    ),
    ArtistSearchItem(
      id: 'mock-rank-4',
      name: 'Kai Pulse',
      handle: '@kaipulse',
      avatarUri: '',
      memberCount: engaged ? 7 : 275000,
      membersLabel: engaged ? '7 interações (7d)' : '275 mil membros',
      rankingValueLabel: engaged
          ? '7 interações (7d)'
          : (active ? '9 posts (7d)' : '275 mil membros'),
      rank: 4,
      trend: 'neutral',
      rankDelta: 0,
      previousRank: 4,
      weeksInRanking: 3,
      peakRank: 4,
    ),
    ArtistSearchItem(
      id: 'mock-rank-5',
      name: 'Nora Wave',
      handle: '@norawave',
      avatarUri: '',
      memberCount: engaged ? 3 : 198000,
      membersLabel: engaged ? '3 interações (7d)' : '198 mil membros',
      rankingValueLabel: engaged
          ? '3 interações (7d)'
          : (active ? '7 posts (7d)' : '198 mil membros'),
      rank: 5,
      trend: 'up',
      rankDelta: 3,
      previousRank: 8,
      weeksInRanking: 2,
      peakRank: 5,
    ),
    ArtistSearchItem(
      id: 'mock-rank-6',
      name: 'Theo Sound',
      handle: '@theosound',
      avatarUri: '',
      memberCount: engaged ? 1 : 156000,
      membersLabel: engaged ? '1 interação (7d)' : '156 mil membros',
      rankingValueLabel: engaged
          ? '1 interação (7d)'
          : (active ? '5 posts (7d)' : '156 mil membros'),
      rank: 6,
      trend: 'down',
      rankDelta: 2,
      previousRank: 4,
      weeksInRanking: 6,
      peakRank: 3,
    ),
    ArtistSearchItem(
      id: 'mock-rank-7',
      name: 'Vera Notes',
      handle: '@veranotes',
      avatarUri: '',
      memberCount: engaged ? 9 : 142000,
      membersLabel: engaged ? '9 interações (7d)' : '142 mil membros',
      rankingValueLabel: engaged
          ? '9 interações (7d)'
          : (active ? '4 posts (7d)' : '142 mil membros'),
      rank: 7,
      trend: 'neutral',
      rankDelta: 0,
      previousRank: 7,
      weeksInRanking: 4,
      peakRank: 7,
    ),
    ArtistSearchItem(
      id: 'mock-rank-8',
      name: 'Omar Stage',
      handle: '@omarstage',
      avatarUri: '',
      memberCount: engaged ? 2 : 121000,
      membersLabel: engaged ? '2 interações (7d)' : '121 mil membros',
      rankingValueLabel: engaged
          ? '2 interações (7d)'
          : (active ? '3 posts (7d)' : '121 mil membros'),
      rank: 8,
      trend: 'up',
      rankDelta: 1,
      previousRank: 9,
      weeksInRanking: 1,
      peakRank: 8,
    ),
  ];
  if (limit >= samples.length) {
    return List<ArtistSearchItem>.from(samples);
  }
  return samples.take(limit).toList(growable: false);
}

/// Motivo de expulsão para Defender retorno (CF-200) quando a API não manda.
const cfTempMockExpulsionReason =
    'A equipe identificou ataques recorrentes e quebra das regras de convivência do fã clube.';

/// Resumo de membership para telas de confirmação (CF-204…207).
const cfTempMockMembershipSummary = (
  artistName: 'Ludmilla',
  planName: 'Membership Oficial',
  priceLabel: 'R\$ 29,90 / mês',
  jamCoinsLabel: '+ 500 Jam Coins',
);

/// Recarga confirmada (CF-204).
const cfTempMockRechargeConfirmed = (
  amountLabel: 'R\$ 50,00',
  jamCoinsLabel: '5.000 Jam Coins',
  methodLabel: 'PIX',
);
