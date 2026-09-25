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
// Outros CFs: acrescentar aqui — não criar outros arquivos em lib/mocks/.
//
// Desligar CF-190: `kUseCf190NotificationMocks = false`
// Forçar vazio: `kCf190MockEmpty = true`
// Remover: apague este arquivo e os imports/`if` nos services que o usam.

import 'package:crowdfans/components/profile/connected_device_row.dart';
import 'package:crowdfans/models/fan_score.dart';
import 'package:crowdfans/services/comment_service.dart';
import 'package:crowdfans/services/community_service.dart';
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

  /// Ranking Top 100 Engajados / Top 500 (CF-193, CF-189).
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
