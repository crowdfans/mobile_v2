// TEMP MOCKS — delete this file when APIs are ready
//
// Único arquivo de fixtures temporários do backlog UX (Gustavo).
// Telas importam daqui; não espalhar arrays falsos nos widgets.

import 'package:crowdfans/services/search_service.dart';

/// Liga o uso de fixtures quando a API devolve vazio / falha.
abstract final class CfTempMocks {
  /// Ranking Top 100 Engajados / Top 500 (CF-193, CF-189).
  static const useRankingFixtures = true;

  /// FanScore insights / how-it-works demos (CF-201, CF-202).
  static const useFanScoreFixtures = true;

  /// Membership / recarga confirmação (CF-204…207).
  static const useMembershipFixtures = true;

  /// Preferências de notificação povoadas (CF-213; CF-190 = outro agente).
  static const useNotificationPrefFixtures = true;

  /// Fã-clube perfil / moderadores / regras (CF-222…230).
  static const useFanClubFixtures = true;

  /// Artistas favoritos no menu lateral (CF-191).
  static const useFavoriteArtistsFixtures = true;
}

/// Linhas de ranking para demo quando `rankArtists` vem vazio.
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
