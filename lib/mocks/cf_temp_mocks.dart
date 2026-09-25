// TEMP MOCKS — delete this file when APIs are ready
//
// Arquivo único de mocks temporários (QA / demo).
// CF-190: central de notificações (print image.png).
// CF-193/189/200+: ranking, expulsão, membership — seções abaixo.
// CF-194: comentários do fã-clube (prints recolhido/expandido).
// CF-195: comentários Home — respostas expandidas.
// CF-178: feed Postagens dos Fã Clubes.
// CF-181: grade Cartas no perfil do artista.
// CF-213/216/217/219: notif artistas, dispositivos, telefone, bio.
// CF-222…230: fã-clube perfil / moderadores / expulsão / aviso.
// CF-232…235/237/239/240/241: home feed, compose, exclusivo, busca, ranking.
// Outros CFs: acrescentar aqui — não criar outros arquivos em lib/mocks/.
//
// Desligar CF-190: `kUseCf190NotificationMocks = false`
// Forçar vazio: `kCf190MockEmpty = true`
// Remover: apague este arquivo e os imports/`if` nos services que o usam.

import 'package:crowdfans/components/fan_club/fan_club_compose_artist.dart';
import 'package:crowdfans/components/profile/connected_device_row.dart';
import 'package:crowdfans/models/fan_score.dart';
<<<<<<< HEAD
import 'package:crowdfans/models/profile.dart';
=======
import 'package:crowdfans/models/feed_post.dart';
import 'package:crowdfans/models/home_feed.dart';
>>>>>>> origin/prod
import 'package:crowdfans/services/comment_service.dart';
import 'package:crowdfans/services/community_service.dart';
import 'package:crowdfans/services/fan_club_service.dart';
import 'package:crowdfans/services/fan_letter_service.dart';
import 'package:crowdfans/services/follow_service.dart';
import 'package:crowdfans/services/notification_preferences_service.dart';
import 'package:crowdfans/services/notifications_service.dart';
import 'package:crowdfans/services/search_service.dart';
import 'package:crowdfans/services/wallet_service.dart';

/// Master: qualquer mock deste arquivo. Preferir flags por feature abaixo.
const bool kUseCfTempMocks = true;

/// CF-190 — inbox povoada (Agora / Hoje) igual ao print.
const bool kUseCf190NotificationMocks = true;

/// CF-190 — lista vazia para validar empty state do print.
const bool kCf190MockEmpty = false;

/// Mocks temporários CrowdFans (um arquivo só).
abstract final class CfTempMocks {
  // --- Feature flags (backlog UX) ---

  /// Ranking Top 100 Engajados / Top 500 (CF-193, CF-189, CF-241).
  static const useRankingFixtures = true;

  /// FanScore insights / how-it-works demos (CF-201, CF-202).
  static const useFanScoreFixtures = true;

  /// Membership / recarga confirmação (CF-204…207).
  static const useMembershipFixtures = true;

  /// Preferências de notificação povoadas (CF-213).
  static const useNotificationPrefFixtures = true;

  /// Segurança / dispositivos / telefone / bio (CF-216, 217, 219).
  static const useSecuritySettingsFixtures = true;

  /// Fã-clube perfil / moderadores / regras / expulsão (CF-200, CF-222…230).
  static const useFanClubFixtures = true;

  /// Home feed vídeo / carrossel / exclusivo (CF-232…235).
  static const useHomeFeedFixtures = true;

  /// Busca artistas (CF-240).
  static const useSearchArtistsFixtures = true;

  /// Seletor de fã-clube no novo post (CF-237).
  static const useFanClubSelectorFixtures = true;

  /// Perfil artista — Exclusivo liberado (CF-239).
  static const useArtistExclusiveFixtures = true;

  /// Painel de moderação — fila do print CF-199 (2 / 2 / 1).
  static const useModerationPanelFixtures = true;

  /// Preferências das subpáginas CF-208 / 209 / 211 (switches do print).
  static const useNotificationCategoryPrintFixtures = true;

  /// Hub Seu Perfil (CF-162) — Aline Duarte quando a API falha/vazio.
  static const useProfileAccountFixtures = true;

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

/// Linhas de ranking para demo quando `rankArtists` vem vazio (CF-193 / CF-189 / CF-241).
List<ArtistSearchItem> cfTempMockRankingArtists({
  required String kind,
  int limit = 8,
}) {
  final engaged = kind == 'engaged';
  final active = kind == 'active';
  final samples = <ArtistSearchItem>[
    ArtistSearchItem(
      id: 'mock-fc-ludmilla',
      name: 'Ludmilla',
      handle: '@ludmilla',
      avatarUri: '',
      memberCount: engaged ? 4 : 512000,
      membersLabel: engaged ? '4 interações (7d)' : '512 mil membros',
      rankingValueLabel: engaged
          ? '4 interações (7d)'
          : (active ? '18 posts (7d)' : '512 mil membros'),
      rank: 1,
      trend: 'up',
      rankDelta: 1,
      previousRank: 2,
      weeksInRanking: 11,
      peakRank: 1,
    ),
    ArtistSearchItem(
      id: 'mock-fc-anitta',
      name: 'Anitta',
      handle: '@anitta',
      avatarUri: '',
      memberCount: engaged ? 0 : 487000,
      membersLabel: engaged ? '0 interações (7d)' : '487 mil membros',
      rankingValueLabel: engaged
          ? '0 interações (7d)'
          : (active ? '14 posts (7d)' : '487 mil membros'),
      rank: 2,
      trend: 'down',
      rankDelta: 1,
      previousRank: 1,
      weeksInRanking: 9,
      peakRank: 1,
    ),
    ArtistSearchItem(
      id: 'mock-fc-mayra',
      name: 'Mayra',
      handle: '@mayra',
      avatarUri: '',
      memberCount: engaged ? 12 : 368000,
      membersLabel: engaged ? '12 interações (7d)' : '368 mil membros',
      rankingValueLabel: engaged
          ? '12 interações (7d)'
          : (active ? '11 posts (7d)' : '368 mil membros'),
      rank: 3,
      trend: 'up',
      rankDelta: 2,
      previousRank: 5,
      weeksInRanking: 8,
      peakRank: 2,
    ),
    ArtistSearchItem(
      id: 'mock-fc-uelo',
      name: 'Banda Uelo',
      handle: '@bandauelo',
      avatarUri: '',
      memberCount: engaged ? 7 : 228000,
      membersLabel: engaged ? '7 interações (7d)' : '228 mil membros',
      rankingValueLabel: engaged
          ? '7 interações (7d)'
          : (active ? '9 posts (7d)' : '228 mil membros'),
      rank: 4,
      trend: 'neutral',
      rankDelta: 0,
      previousRank: 4,
      weeksInRanking: 6,
      peakRank: 3,
    ),
    ArtistSearchItem(
      id: 'mock-fc-carol',
      name: 'Carol Biazin',
      handle: '@carolbiazin',
      avatarUri: '',
      memberCount: engaged ? 3 : 196000,
      membersLabel: engaged ? '3 interações (7d)' : '196 mil membros',
      rankingValueLabel: engaged
          ? '3 interações (7d)'
          : (active ? '7 posts (7d)' : '196 mil membros'),
      rank: 5,
      trend: 'up',
      rankDelta: 3,
      previousRank: 8,
      weeksInRanking: 4,
      peakRank: 5,
    ),
    ArtistSearchItem(
      id: 'mock-fc-enzo',
      name: 'Enzo Lima',
      handle: '@enzolima',
      avatarUri: '',
      memberCount: engaged ? 1 : 11841,
      membersLabel: engaged ? '1 interação (7d)' : '11.841 membros',
      rankingValueLabel: engaged
          ? '1 interação (7d)'
          : (active ? '5 posts (7d)' : '11.841 membros'),
      rank: 6,
      trend: 'down',
      rankDelta: 2,
      previousRank: 4,
      weeksInRanking: 3,
      peakRank: 4,
    ),
    ArtistSearchItem(
      id: 'mock-fc-marinhos',
      name: 'Marinhos',
      handle: '@marinhos',
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
      weeksInRanking: 2,
      peakRank: 7,
    ),
    ArtistSearchItem(
      id: 'mock-fc-kheper',
      name: 'Kheper',
      handle: '@kheperrrr',
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

/// Motivo de expulsão para Defender retorno (CF-200 / CF-229) quando a API não manda.
const cfTempMockExpulsionReason =
    'A equipe identificou ataques recorrentes e quebra das regras de convivência do fã clube.';

/// Motivo de aviso de moderação (CF-230).
const cfTempMockStrikeReason =
    'Você insistiu em provocações repetidas nos comentários mesmo depois de avisos da equipe.';

/// CF-199 — fila Contestações 2 / Avisos 2 / Expulsos 1 (image1.png).
abstract final class Cf199ModerationPanelFixtures {
  static const _avatarAnna =
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=100&q=80';
  static const _avatarVic =
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=100&q=80';

  static List<FanClubAppeal> appeals() {
    return const [
      FanClubAppeal(
        appealId: 'cf199-appeal-anna',
        expulsionId: 'cf199-exp-anna',
        requesterUid: 'cf199-anna',
        displayName: 'Anna Lu',
        handle: 'annalu',
        photoUrl: _avatarAnna,
        defense:
            'Eu entendi o motivo da expulsão, apaguei as publicações e quero voltar para contribuir de forma respeitosa.',
        status: 'pending',
        createdAt: '2026-01-01T12:00:00Z',
      ),
      FanClubAppeal(
        appealId: 'cf199-appeal-vic',
        expulsionId: 'cf199-exp-vic',
        requesterUid: 'cf199-vic',
        displayName: 'Vic Melo',
        handle: 'vicmelo',
        photoUrl: _avatarVic,
        defense:
            'Quero explicar o contexto da discussão e mostrar que segui as orientações da moderação depois do caso.',
        status: 'pending',
        createdAt: '2026-01-01T13:00:00Z',
      ),
    ];
  }

  static List<FanClubStrike> strikes() {
    return const [
      FanClubStrike(
        strikeId: 'cf199-strike-1',
        targetUid: 'cf199-fan-a',
        displayName: 'Fan A',
        handle: 'fana',
        photoUrl: '',
        reason: 'Linguagem agressiva em comentários do feed.',
        remainingChances: 2,
        issuedByUid: 'mod-1',
        createdAt: '2026-01-01T10:00:00Z',
      ),
      FanClubStrike(
        strikeId: 'cf199-strike-2',
        targetUid: 'cf199-fan-b',
        displayName: 'Fan B',
        handle: 'fanb',
        photoUrl: '',
        reason: 'Spam de links externos no chat da comunidade.',
        remainingChances: 1,
        issuedByUid: 'mod-1',
        createdAt: '2026-01-01T11:00:00Z',
      ),
    ];
  }

  static List<FanClubExpulsion> expulsions() {
    return const [
      FanClubExpulsion(
        expulsionId: 'cf199-exp-1',
        targetUid: 'cf199-fan-c',
        displayName: 'Fan C',
        handle: 'fanc',
        photoUrl: '',
        reason: 'Ataques recorrentes após avisos prévios.',
        issuedByUid: 'mod-1',
        createdAt: '2026-01-01T09:00:00Z',
      ),
    ];
  }
}

/// CF-208 / 209 / 211 — switches iguais aos prints das subpáginas.
abstract final class Cf208209211NotificationPrintFixtures {
  static Map<String, bool> preferences() {
    return {
      ...notificationPreferenceDefaults,
      // CF-208 — todos off no print.
      NotificationPreferenceKeys.artistLikeComment: false,
      NotificationPreferenceKeys.artistLikeFanLetter: false,
      NotificationPreferenceKeys.commentReplies: false,
      NotificationPreferenceKeys.mentions: false,
      NotificationPreferenceKeys.newFollowers: false,
      // CF-209 — convites e lembretes on; resultado off.
      NotificationPreferenceKeys.meetInvites: true,
      NotificationPreferenceKeys.meetReminders: true,
      NotificationPreferenceKeys.meetResults: false,
      // CF-211 — renovação e saldo on; promo off.
      NotificationPreferenceKeys.membershipRenewals: true,
      NotificationPreferenceKeys.jamCoinsPromos: false,
      NotificationPreferenceKeys.jamCoinsBalance: true,
    };
  }
}

/// CF-162 — hub Seu Perfil (print Aline Duarte).
abstract final class Cf162ProfileAccountFixtures {
  static const Profile aline = Profile(
    userUid: 'cf162-aline',
    displayName: 'fan/alineduarte',
    name: 'Aline Duarte',
    description: '',
    photoUrl: '',
    isArtist: false,
  );
}

/// Resumo de membership para telas de confirmação (CF-204…207).
const cfTempMockMembershipSummary = (
  artistName: 'Banda Uelo',
  artistHandle: '@bandauelo',
  artistId: 'mock-membership-uelo',
  planName: 'Membership Oficial',
  pricePerMonth: 240,
  jamCoinsBalanceLabel: '2.684',
  periodLabel: '1 mês',
);

/// Gerenciar membership (CF-205) — print Marinhos / 240 / 3 meses.
const cfTempMockMembershipManage = (
  artistName: 'Marinhos',
  artistHandle: '@marinhos',
  artistId: 'mock-membership-marinhos',
  pricePerMonth: 240,
  monthsLabel: '3 meses',
);

/// Recarga confirmada (CF-204) — print: 240 = 200 JC + 40 bônus.
const cfTempMockRechargeConfirmed = (
  coinsTotal: 240,
  baseCoins: 200,
  bonusCoins: 40,
);

/// FanScore demo do print CF-201 (ciclo + cards Ultimate/Super).
FanScoreData cfTempMockFanScoreData() {
  const ultimate = FanScoreTier(
    id: 'ultimate',
    label: 'Ultimate Fan',
    minScore: 900,
    gradient: ['#EDE9FE', '#DDD6FE'],
    badgeGradient: ['#A78BFA', '#7C3AED'],
    badgeText: '#FFFFFF',
    border: '#C4B5FD',
  );
  const superFan = FanScoreTier(
    id: 'super',
    label: 'Super Fan',
    minScore: 500,
    gradient: ['#FFEDD5', '#FED7AA'],
    badgeGradient: ['#FB923C', '#EA580C'],
    badgeText: '#FFFFFF',
    border: '#FDBA74',
  );
  const superFanAlt = FanScoreTier(
    id: 'super',
    label: 'Super Fan',
    minScore: 500,
    gradient: ['#FEF9C3', '#FDE68A'],
    badgeGradient: ['#FB923C', '#EA580C'],
    badgeText: '#FFFFFF',
    border: '#FCD34D',
  );
  return const FanScoreData(
    cycleDetails: FanScoreCycleDetails(
      periodLabel: 'Agosto 2026',
      cycleLabel: 'Agosto 2026',
      endLabel: 'segunda-feira, 31/08/2026 às 23:59',
      helperText:
          'O ciclo vigente encerra em segunda-feira, 31/08/2026 às 23:59 e reseta logo em seguida.',
    ),
    entries: [
      FanScoreEntry(
        artistId: 'mock-fs-kheper',
        artistName: 'Kheper',
        artistAvatarUri: '',
        memberCount: '141k',
        currentScore: 1000,
        deltaPercentage: 4,
        fanRank: 7,
        breakdown: FanScoreBreakdown(
          hasMembership: true,
          commentsMade: 100,
          upvotesMade: 60,
          fanLettersPosted: 20,
          liveDonations: 5,
          liveParticipations: 5,
          fanClubPosts: 10,
        ),
        tier: ultimate,
      ),
      FanScoreEntry(
        artistId: 'mock-fs-marinhos',
        artistName: 'Marinhos',
        artistAvatarUri: '',
        memberCount: '173k',
        currentScore: 973,
        deltaPercentage: 21,
        fanRank: 15,
        breakdown: FanScoreBreakdown(
          hasMembership: true,
          commentsMade: 80,
          upvotesMade: 40,
          fanLettersPosted: 12,
          liveDonations: 3,
          liveParticipations: 4,
          fanClubPosts: 8,
        ),
        tier: superFan,
      ),
      FanScoreEntry(
        artistId: 'mock-fs-uelo',
        artistName: 'Banda Uelo',
        artistAvatarUri: '',
        memberCount: '228k',
        currentScore: 560,
        deltaPercentage: 12,
        fanRank: 48,
        breakdown: FanScoreBreakdown(
          hasMembership: false,
          commentsMade: 40,
          upvotesMade: 22,
          fanLettersPosted: 6,
          liveDonations: 1,
          liveParticipations: 2,
          fanClubPosts: 5,
        ),
        tier: superFanAlt,
      ),
    ],
  );
}

/// Liga dados de demo do CF-194 (lista vazia/erro no fã-clube → print populado).
const bool kUseCf194CommentMocks = true;

/// Dados do print CF-194 (recolhido / expandido).
abstract final class Cf194FanClubCommentsMock {
  static const postAuthor = 'Felipe Rhy';
  static const postHandle = 'fan/thiagok';
  static const postText =
      'Se abrirem novo meet & greet, a gente precisa entrar mais coordenado dessa vez.';
  static const clubName = 'Thiago K';
  static const postMinutesAgo = 120;
  static const postVotes = 1039;
  static const postShares = 20;

  static const parentHandle = 'fan/feandrade';

  static List<CommentItem> comments() {
    final reply = CommentItem(
      id: 'cf194-reply-1',
      author: 'Rafa Nogueira',
      handle: 'fan/rafanogueira',
      avatarUri: '',
      minutesAgo: 180,
      text: 'Esse tipo de conteúdo sempre rende discussão boa.',
      votes: 15,
      parentCommentId: 'cf194-c1',
    );
    return [
      CommentItem(
        id: 'cf194-c1',
        author: 'Fê Andrade',
        handle: parentHandle,
        avatarUri: '',
        minutesAgo: 180,
        text:
            'Quero mais posts de bastidor assim. Dá vontade de salvar tudo e mandar no grupo do fandom.',
        votes: 229,
        replies: [reply],
      ),
    ];
  }
}

/// CF-213 — Artistas e Fã Clubes (print: tipos off + Mayra / Laís / Marinhos).
extension Cf213NotificationPrefFixtures on CfTempMocks {
  static Map<String, bool> alertTypeDefaultsOff() {
    return {
      ...notificationPreferenceDefaults,
      NotificationPreferenceKeys.clubPosts: false,
      NotificationPreferenceKeys.exclusiveContent: false,
      NotificationPreferenceKeys.fanLetterReceived: false,
      NotificationPreferenceKeys.artistHighlights: false,
    };
  }

  static List<ArtistFollow> followedArtists() {
    return const [
      ArtistFollow(
        artistUid: 'cf213-mayra',
        artistName: 'Mayra',
        avatarUrl: '',
        isFollowing: true,
      ),
      ArtistFollow(
        artistUid: 'cf213-lais',
        artistName: 'Laís Costa',
        avatarUrl: '',
        isFollowing: true,
      ),
      ArtistFollow(
        artistUid: 'cf213-marinhos',
        artistName: 'Marinhos',
        avatarUrl: '',
        isFollowing: true,
      ),
    ];
  }

  static const artistSubtitles = <String>[
    'Posts, cartas, Meet & Greet e membership deste artista.',
    'Lembretes de Meet, destaques e novidades do fã clube.',
    'Renovação de membership, promoções e conteúdo exclusivo.',
  ];
}

/// CF-216 — três sessões do print.
extension Cf216ConnectedDevicesFixtures on CfTempMocks {
  static List<ConnectedDeviceSession> sessions() {
    return const [
      ConnectedDeviceSession(
        id: 'current',
        name: 'iPhone 15 Pro',
        platformLine: 'iOS · Crowd Fans App',
        location: 'São Paulo, Brasil',
        activity: 'Ativo agora',
        isCurrent: true,
        isPhone: true,
      ),
      ConnectedDeviceSession(
        id: 'macbook',
        name: 'MacBook Air',
        platformLine: 'Chrome · Web',
        location: 'São Paulo, Brasil',
        activity: 'Hoje às 14:12',
        isCurrent: false,
        isPhone: false,
      ),
      ConnectedDeviceSession(
        id: 'galaxy',
        name: 'Galaxy S24',
        platformLine: 'Android · Crowd Fans App',
        location: 'Campinas, Brasil',
        activity: 'Ontem às 22:41',
        isCurrent: false,
        isPhone: true,
      ),
    ];
  }
}

/// CF-217 — telefone atual do print.
abstract final class Cf217ChangePhoneMock {
  static const currentPhoneLabel = '(11) 98765-4321';
}

/// CF-219 — bio do print (contador 56).
abstract final class Cf219EditBioMock {
  static const bio =
      'Gosto muito di rock e pop, se vc gosta tb vamos ser ami!';
}

/// Liga dados de demo do CF-195 (Home sem comentários → print populado).
const bool kUseCf195CommentMocks = true;

/// Dados do print CF-195 (Home — pai + resposta expandida + thread recolhida).
abstract final class Cf195HomeCommentsMock {
  static const postAuthor = 'Ponzanelli';
  static const postHandle = '@ponzanelli';
  static const parentHandle = 'fan/feandrade';

  static List<CommentItem> comments() {
    final expandedReply = CommentItem(
      id: 'cf195-reply-1',
      author: 'Rafa Nogueira',
      handle: 'fan/rafanogueira',
      avatarUri: '',
      minutesAgo: 180,
      text: 'Esse tipo de conteúdo sempre rende discussão boa.',
      votes: 15,
      parentCommentId: 'cf195-c1',
    );
    final collapsedA = CommentItem(
      id: 'cf195-reply-2a',
      author: 'Lia Costa',
      handle: 'fan/liacosta',
      avatarUri: '',
      minutesAgo: 90,
      text: 'Concordo demais.',
      votes: 4,
      parentCommentId: 'cf195-c2',
    );
    final collapsedB = CommentItem(
      id: 'cf195-reply-2b',
      author: 'Bruno M.',
      handle: 'fan/brunom',
      avatarUri: '',
      minutesAgo: 60,
      text: 'Salvei aqui.',
      votes: 2,
      parentCommentId: 'cf195-c2',
    );
    return [
      CommentItem(
        id: 'cf195-c1',
        author: 'Fê Andrade',
        handle: parentHandle,
        avatarUri: '',
        minutesAgo: 180,
        text:
            'Quero mais posts de bastidor assim. Dá vontade de salvar tudo e mandar no grupo do fandom.',
        votes: 229,
        replies: [expandedReply],
      ),
      CommentItem(
        id: 'cf195-c2',
        author: 'Camila R.',
        handle: 'fan/camilar',
        avatarUri: '',
        minutesAgo: 120,
        text: 'Alguém mais ficou com vontade de ver o making of completo?',
        votes: 48,
        replies: [collapsedA, collapsedB],
      ),
    ];
  }
}

// --- CF-222…230 fã-clube / CF-232…241 feed-busca ---

const _cfCarouselBeach =
    'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80';
const _cfCarouselDeer =
    'https://images.unsplash.com/photo-1484406566174-9da000fda645?auto=format&fit=crop&w=800&q=80';
const _cfCarouselCity =
    'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?auto=format&fit=crop&w=800&q=80';
const _cfCarouselSnake =
    'https://images.unsplash.com/photo-1531386450450-969f935bd522?auto=format&fit=crop&w=800&q=80';
const _cfCarouselMerch =
    'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?auto=format&fit=crop&w=800&q=80';

enum CfFanClubFixtureKind { community, expelled, warning }

/// Escolhe variante do print pelo artistUid (Felipe→expulsão, Laís→aviso, senão Enzo).
CfFanClubFixtureKind cfTempMockFanClubKind(String artistUid) {
  final id = artistUid.trim().toLowerCase();
  if (id.contains('felipe') ||
      id.contains('rhy') ||
      id.contains('expuls') ||
      id == 'cf229' ||
      id.endsWith('-expelled')) {
    return CfFanClubFixtureKind.expelled;
  }
  if (id.contains('lais') ||
      id.contains('laís') ||
      id.contains('strike') ||
      id == 'cf230' ||
      id.endsWith('-warning')) {
    return CfFanClubFixtureKind.warning;
  }
  return CfFanClubFixtureKind.community;
}

List<FanClubModerator> cfTempMockFanClubModerators() {
  return const [
    FanClubModerator(
      userUid: 'cf-mod-aline',
      handle: 'alineduarte',
      displayName: 'Aline Duarte',
      photoUrl: '',
      role: 'moderator',
    ),
    FanClubModerator(
      userUid: 'cf-mod-maria',
      handle: 'mariaeduarda',
      displayName: 'Maria Eduarda',
      photoUrl: '',
      role: 'moderator',
    ),
    FanClubModerator(
      userUid: 'cf-mod-lari',
      handle: 'larirocha',
      displayName: 'Lari Rocha',
      photoUrl: '',
      role: 'moderator',
    ),
  ];
}

/// Feed do fã-clube alinhado aos prints CF-222 / 229 / 230.
ArtistFanClubFeed cfTempMockArtistFanClubFeed(
  String artistUid, {
  int page = 1,
}) {
  if (page > 1) {
    final kind = cfTempMockFanClubKind(artistUid);
    final club = _cfTempMockFanClubMeta(artistUid, kind);
    return ArtistFanClubFeed(fanClub: club, posts: const []);
  }
  final kind = cfTempMockFanClubKind(artistUid);
  final club = _cfTempMockFanClubMeta(artistUid, kind);
  final posts = switch (kind) {
    CfFanClubFixtureKind.community => [
      FanClubFeedPost(
        postId: 'cf222-aline-merch',
        content:
            'Minha coleção de merch agora ficou boa o bastante pra render um post inteiro.',
        createdAt: DateTime.now()
            .subtract(const Duration(minutes: 18))
            .toIso8601String(),
        type: 'carousel',
        imageUrl: _cfCarouselSnake,
        carouselUris: const [_cfCarouselSnake, _cfCarouselMerch],
        likesCount: 42,
        commentsCount: 8,
        sharesCount: 3,
        authorName: 'Aline Duarte',
        authorHandle: 'fan/alineduarte',
        authorAvatarUri: '',
        membershipMonthsLabel: '3',
      ),
    ],
    CfFanClubFixtureKind.expelled => const <FanClubFeedPost>[],
    CfFanClubFixtureKind.warning => [
      FanClubFeedPost(
        postId: 'cf230-lari-bh',
        content:
            'Saí do trabalho e fui direto pra fila. Trouxe brinde pro pessoal do fã clube de BH.',
        createdAt: DateTime.now()
            .subtract(const Duration(hours: 1))
            .toIso8601String(),
        type: 'image',
        imageUrl: _cfCarouselCity,
        likesCount: 88,
        commentsCount: 14,
        sharesCount: 5,
        authorName: 'Lari Rocha',
        authorHandle: 'fan/larirocha',
        authorAvatarUri: '',
        membershipMonthsLabel: '1',
      ),
    ],
  };
  return ArtistFanClubFeed(fanClub: club, posts: posts);
}

ArtistFanClub _cfTempMockFanClubMeta(
  String artistUid,
  CfFanClubFixtureKind kind,
) {
  final mods = cfTempMockFanClubModerators();
  return switch (kind) {
    CfFanClubFixtureKind.community => ArtistFanClub(
      id: 222,
      name: 'Enzo Lima',
      description: 'Fã clube de Enzo Lima',
      artistUid: artistUid.trim().isEmpty ? 'mock-fc-enzo' : artistUid,
      artistName: 'Enzo Lima',
      isActive: true,
      memberCount: 11841,
      isMember: true,
      moderators: mods,
    ),
    CfFanClubFixtureKind.expelled => ArtistFanClub(
      id: 229,
      name: 'Felipe Rhy',
      description: 'Fã clube de Felipe Rhy',
      artistUid: artistUid.trim().isEmpty ? 'mock-fc-felipe' : artistUid,
      artistName: 'Felipe Rhy',
      isActive: true,
      memberCount: 6972,
      isMember: false,
      viewerIsExpelled: true,
      viewerExpulsionReason: cfTempMockExpulsionReason,
      moderators: mods,
    ),
    CfFanClubFixtureKind.warning => ArtistFanClub(
      id: 230,
      name: 'Laís Costa Fã Clube',
      description: 'Fã clube de Laís Costa',
      artistUid: artistUid.trim().isEmpty ? 'mock-fc-lais' : artistUid,
      artistName: 'Laís Costa',
      isActive: true,
      memberCount: 8225,
      isMember: true,
      viewerActiveStrikesCount: 1,
      viewerLatestStrikeReason: cfTempMockStrikeReason,
      viewerStrikeRemainingChances: 2,
      moderators: mods,
    ),
  };
}

/// Candidato na tela Solicitar moderação (CF-224 print).
const cfTempMockModerationCandidate = (
  displayName: 'Aline Duarte',
  handle: 'fan/alineduarte',
  photoUrl: '',
);

/// Home feed — vídeo / carrossel / exclusivo (CF-232 / 233 / 235).
List<FeedPost> cfTempMockHomeFeedPosts() {
  return const [
    FeedPost(
      id: 'cf232-uelo-video',
      type: PostType.video,
      author: 'Banda Uelo',
      artistId: 'mock-fc-uelo',
      handle: '@bandauelo',
      rank: '#18',
      minutesAgo: 31,
      avatarUri: '',
      text:
          'Prévia do vídeo da passagem de som. Perfeito pra testar autoplay no feed.',
      votes: 136,
      comments: 31,
      shares: 11,
      videoDuration: '00:00',
      videoUri: '',
      videoThumbnailUri: '',
    ),
    FeedPost(
      id: 'cf233-ponzanelli-carousel',
      type: PostType.carousel,
      author: 'Ponzanelli',
      artistId: 'mock-fc-ponzanelli',
      handle: '@ponzanelli',
      minutesAgo: 60,
      avatarUri: '',
      text:
          'Momentos do backstage que normalmente não entram em lugar nenhum. Agora entraram.',
      votes: 227,
      comments: 31,
      shares: 5,
      imageUri: _cfCarouselBeach,
      carouselUris: [_cfCarouselBeach, _cfCarouselDeer, _cfCarouselCity],
    ),
    FeedPost(
      id: 'cf235-mayra-exclusive',
      type: PostType.video,
      author: 'Mayra',
      artistId: 'mock-fc-mayra',
      handle: '@mayra',
      rank: '#3',
      minutesAgo: 60,
      avatarUri: '',
      text:
          'Versão acústica gravada no camarim. Agora finalmente posso subir isso aqui.',
      votes: 201,
      comments: 21,
      shares: 11,
      isExclusive: true,
      exclusiveLocked: false,
      videoDuration: '00:00',
      videoUri: '',
      videoThumbnailUri: '',
    ),
    FeedPost(
      id: 'cf232-carol-text',
      type: PostType.text,
      author: 'Carol Biazin',
      artistId: 'mock-fc-carol',
      handle: '@carolbiazin',
      minutesAgo: 36,
      avatarUri: '',
      text:
          'Obrigada por cada mensagem depois último post. Vocês deixam tudo mais leve aqui.',
      votes: 98,
      comments: 12,
      shares: 4,
    ),
  ];
}

HomeFeedDto cfTempMockHomeFeedDto({int page = 1}) {
  if (page > 1) {
    return const HomeFeedDto(
      feedPosts: [],
      stories: [],
      hasMore: false,
    );
  }
  return HomeFeedDto(
    feedPosts: cfTempMockHomeFeedPosts(),
    stories: const [],
    hasMore: false,
  );
}

/// Seletor Novo post → Fã Clube (CF-237).
List<FanClubComposeArtist> cfTempMockFanClubSelectorArtists() {
  return const [
    FanClubComposeArtist(id: 'mock-fc-mayra', name: 'Mayra'),
    FanClubComposeArtist(id: 'mock-fc-marinhos', name: 'Marinhos'),
    FanClubComposeArtist(id: 'mock-fc-uelo', name: 'Banda Uelo'),
    FanClubComposeArtist(id: 'mock-fc-enzo', name: 'Enzo Lima'),
    FanClubComposeArtist(id: 'mock-fc-ludmilla', name: 'Ludmilla'),
    FanClubComposeArtist(id: 'mock-fc-anitta', name: 'Anitta'),
  ];
}

/// Exclusivo liberado no perfil (CF-239) — Ludmilla assinante.
bool cfTempMockArtistExclusiveSubscribed(String artistId, String? name) {
  final id = artistId.trim().toLowerCase();
  final n = (name ?? '').trim().toLowerCase();
  return id.contains('ludmilla') ||
      id == 'mock-fc-ludmilla' ||
      n.contains('ludmilla');
}

List<FeedPost> cfTempMockLudmillaExclusivePosts() {
  return const [
    FeedPost(
      id: 'cf239-lud-1',
      type: PostType.carousel,
      author: 'Ludmilla',
      artistId: 'mock-fc-ludmilla',
      handle: '@ludmilla',
      minutesAgo: 25,
      avatarUri: '',
      text:
          'Hoje foi estúdio, prova de look e conversa longa com a equipe. Resolvi largar tudo aqui.',
      votes: 123,
      comments: 26,
      shares: 9,
      isExclusive: true,
      exclusiveLocked: false,
      imageUri: _cfCarouselDeer,
      carouselUris: [_cfCarouselDeer, _cfCarouselBeach, _cfCarouselCity],
    ),
    FeedPost(
      id: 'cf239-lud-2',
      type: PostType.image,
      author: 'Ludmilla',
      artistId: 'mock-fc-ludmilla',
      handle: '@ludmilla',
      minutesAgo: 60,
      avatarUri: '',
      text: 'Visual novo, teste de luz e foto roubada de bastidor.',
      votes: 88,
      comments: 14,
      shares: 3,
      isExclusive: true,
      exclusiveLocked: false,
      imageUri: _cfCarouselMerch,
    ),
  ];
}

/// Busca artistas “L” (CF-240).
List<ArtistSearchItem>? cfTempMockSearchArtists(String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) {
    return null;
  }
  final all = cfTempMockRankingArtists(kind: 'fan-clubs', limit: 5);
  if (q == 'l') {
    return all;
  }
  final filtered = [
    for (final item in all)
      if (item.name.toLowerCase().startsWith(q) ||
          item.handle.toLowerCase().contains(q))
        item,
  ];
  return filtered.isEmpty ? null : filtered;
}

/// Liga feed demo CF-178 (Postagens dos Fã Clubes vazio → print).
const bool kUseCf178FanClubsFeedMocks = true;

/// Posts do print CF-178 (Felipe Rhy + Laís Costa carrossel).
abstract final class Cf178FanClubsFeedMock {
  static List<CommunityPost> posts() {
    return const [
      CommunityPost(
        id: 'cf178-1',
        type: 'text',
        author: 'Felipe Rhy',
        handle: 'fan/thiagok',
        minutesAgo: 120,
        avatarUri: '',
        text:
            'Se abrirem novo meet & greet, a gente precisa entrar mais coordenado dessa vez.',
        votes: 1039,
        comments: 69,
        shares: 20,
      ),
      CommunityPost(
        id: 'cf178-2',
        type: 'carousel',
        author: 'Laís Costa',
        handle: 'fan/fefe_cf',
        minutesAgo: 120,
        avatarUri: '',
        text:
            'Dias de gravação, espera e conversa até tarde. Resolvi largar tudo nesse carrossel.',
        imageUri:
            'https://images.unsplash.com/photo-1491002052546-bf38f386af0e?auto=format&fit=crop&w=800&q=80',
        votes: 412,
        comments: 28,
        shares: 11,
      ),
    ];
  }
}

/// Liga grade demo CF-181 (Cartas vazias → print povoado).
const bool kUseCf181CartasMocks = true;

/// Cartas do print CF-181 (autoria no topo da grade).
abstract final class Cf181CartasMock {
  static List<FanLetter> letters({required String artistId}) {
    return [
      FanLetter(
        id: 'cf181-1',
        artistId: artistId,
        artistName: 'Ludmilla',
        fanDisplayName: 'Aline Duarte',
        fanHandle: 'alineduarte',
        fanAvatarUri: '',
        votesCount: 12,
        sendsCount: 1,
        artistUpvoted: false,
        postedAt: 0,
        bodyText: 'xhxucucucic',
        backgroundId: 'night',
      ),
      FanLetter(
        id: 'cf181-2',
        artistId: artistId,
        artistName: 'Ludmilla',
        fanDisplayName: 'Caio Loux',
        fanHandle: 'caioloux',
        fanAvatarUri: '',
        votesCount: 8,
        sendsCount: 1,
        artistUpvoted: false,
        postedAt: 0,
        bodyText: 'Teu show foi incrível',
        backgroundId: 'grad-lilac',
      ),
      FanLetter(
        id: 'cf181-3',
        artistId: artistId,
        artistName: 'Ludmilla',
        fanDisplayName: 'Nina Costa',
        fanHandle: 'ninacosta',
        fanAvatarUri: '',
        votesCount: 5,
        sendsCount: 1,
        artistUpvoted: false,
        postedAt: 0,
        bodyText: 'TEU SOM ME SALVA',
        backgroundId: 'blush',
      ),
      FanLetter(
        id: 'cf181-4',
        artistId: artistId,
        artistName: 'Ludmilla',
        fanDisplayName: 'Vic Melo',
        fanHandle: 'vicmelo',
        fanAvatarUri: '',
        votesCount: 3,
        sendsCount: 1,
        artistUpvoted: false,
        postedAt: 0,
        bodyText: 'SHOW LOTADO',
        backgroundId: 'sky-soft',
      ),
      FanLetter(
        id: 'cf181-5',
        artistId: artistId,
        artistName: 'Ludmilla',
        fanDisplayName: 'Rafa Nogueira',
        fanHandle: 'rafanogueira',
        fanAvatarUri: '',
        votesCount: 2,
        sendsCount: 1,
        artistUpvoted: false,
        postedAt: 0,
        bodyText: 'VOCE ACENOU',
        backgroundId: 'solid-butter',
      ),
      FanLetter(
        id: 'cf181-6',
        artistId: artistId,
        artistName: 'Ludmilla',
        fanDisplayName: 'Lia Costa',
        fanHandle: 'liacosta',
        fanAvatarUri: '',
        votesCount: 1,
        sendsCount: 1,
        artistUpvoted: false,
        postedAt: 0,
        bodyText: 'MEU CONFORTO',
        backgroundId: 'grad-peach',
      ),
    ];
  }
}

/// Liga pacotes demo CF-170 (pagamento print 240 / R$ 19,90).
const bool kUseCf170WalletPackMocks = true;

/// Pacote do print CF-170.
abstract final class Cf170WalletPackMock {
  static List<JamCoinPack> packs() {
    return const [
      JamCoinPack(
        id: 'cf170-240',
        coins: 240,
        priceCents: 1990,
        label: '200 JC + 40 bônus',
      ),
    ];
  }
}
