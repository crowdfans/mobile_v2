// TEMP MOCKS — delete this file when APIs are ready
//
// Arquivo único de mocks temporários (QA / demo).
// CF-190: central de notificações (print image.png).
// CF-193/189/200+: ranking, expulsão, membership — seções abaixo.
// CF-194: comentários do fã-clube (prints recolhido/expandido).
// CF-195: comentários Home — respostas expandidas.
// CF-197: seletor de GIF (featured / busca / vazio; erro sem API key).
// CF-198: Central de ajuda — demock (HelpContent oficial; flags off).
// CF-178: feed Postagens dos Fã Clubes.
// CF-171: checkout PIX pendente (etapas 01/02/03 + código).
// CF-181: grade Cartas no perfil do artista.
// CF-187: Meu Perfil preenchido (seletor + stats/bio/posts do print).
// CF-213/216/219: notif artistas, dispositivos, bio.
// CF-217 telefone: demock (API CF-271 PUT /profile + Firebase).
// CF-222…230: fã-clube perfil / moderadores / expulsão / aviso.
// CF-232…235/237/239/240/241: home feed, compose, exclusivo, busca, ranking.
// CF-176: menu ⋯ do post (home) — ícones/rótulos/destaques do print.
// CF-185: perfil artista Feed — capa + CTA Seguir/Membership♪/Membership✓.
// CF-191: menu lateral Favoritos / Seus Artistas (print).
// Outros CFs: acrescentar aqui — não criar outros arquivos em lib/mocks/.
//
// Desligar CF-190: `kUseCf190NotificationMocks = false`
// Forçar vazio: `kCf190MockEmpty = true`
// Remover: apague este arquivo e os imports/`if` nos services que o usam.

import 'package:crowdfans/components/fan_club/fan_club_compose_artist.dart';
import 'package:crowdfans/components/fan_letter/fan_letter_canvas_preview.dart';
import 'package:crowdfans/components/profile/connected_device_row.dart';
import 'package:crowdfans/content/help_content.dart';
import 'package:crowdfans/models/fan_profile.dart';
import 'package:crowdfans/models/fan_score.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:crowdfans/models/home_feed.dart';
import 'package:crowdfans/models/profile.dart';
import 'package:crowdfans/services/comment_gif_service.dart';
import 'package:crowdfans/services/comment_service.dart';
import 'package:crowdfans/services/community_service.dart';
import 'package:crowdfans/services/fan_club_service.dart';
import 'package:crowdfans/services/fan_letter_service.dart';
import 'package:crowdfans/services/follow_service.dart';
import 'package:crowdfans/services/notification_preferences_service.dart';
import 'package:crowdfans/services/notifications_service.dart';
import 'package:crowdfans/services/search_service.dart';
import 'package:crowdfans/services/wallet_service.dart';
import 'package:flutter/material.dart';

/// Master: qualquer mock deste arquivo. Preferir flags por feature abaixo.
/// Só desligar flag depois da feature real (backend + front). CF-266/267 OK.
const bool kUseCfTempMocks = true;

/// CF-190 — inbox. Off: API CF-267 (posts/clubs/meet/fanletter/system + unread).
const bool kUseCf190NotificationMocks = false;

/// CF-190 — lista vazia para validar empty state do print.
const bool kCf190MockEmpty = false;

/// CF-191 — força menu lateral vazio (sem favoritos/artistas).
const bool kCf191MockEmpty = false;

/// Mocks temporários CrowdFans (um arquivo só).
abstract final class CfTempMocks {
  // --- Feature flags (backlog UX) ---

  /// Ranking Top 100/500 + sheet (CF-172/189/193/241). Off: API CF-268
  /// entrega `weeksInRanking`/`peakRank` via snapshots semanais.
  static const useRankingFixtures = false;

  /// FanScore — `GET /api/v1/profiles/:handle/fan-score`.
  /// **TEMP on** (CF-201): API existe, mas prod não devolve o ciclo + cards
  /// Ultimate/Super do print (Insights expandido). Off quando o endpoint
  /// popular dados equivalentes ao print.
  static const useFanScoreFixtures = true;

  /// Membership / recarga — subscriptions + wallet APIs.
  /// Off: Assinar (CF-206) e hub usam API real; não ligar para print CF-207.
  static const useMembershipFixtures = false;

  /// CF-205 Gerenciar membership — deep-link vazio / preço ≤ 0 usa
  /// [cfTempMockMembershipManage] (Marinhos / 240 / 3 meses). TEMP até QA
  /// abrir sempre com params da assinatura real. Não liga Assinar (CF-206).
  static const useMembershipManageFixtures = true;

  /// CF-207 confirmação de ativação — deep-link vazio / preço ≤ 0 usa
  /// [cfTempMockMembershipSummary] (Banda Uelo / 240). TEMP até QA abrir
  /// sempre com params da assinatura real. Não liga Assinar (CF-206).
  static const useMembershipActivationConfirmedFixtures = true;

  /// Preferências — `GET/PUT /api/v1/notifications/preferences`.
  /// Genérico off: CF-213 usa [useArtistsNotifPrintFixtures].
  static const useNotificationPrefFixtures = false;

  /// CF-213 Artistas e Fã Clubes — tipos off + Mayra/Laís/Marinhos do print.
  /// TEMP até preferências/follows reais baterem o estado de referência do QA.
  /// Não liga hub CF-166 nem CF-209/211.
  static const useArtistsNotifPrintFixtures = true;

  /// Segurança genérica. Off: API real [CF-266] `/me/sessions`.
  /// Telefone/bio: screens usam perfil/Firebase, não este flag.
  /// CF-216 print fixtures: [kUseCf216ConnectedDevicesMocks] (off = API).
  static const useSecuritySettingsFixtures = false;

  /// Fã-clube — `GET /api/v1/artist/:uid/fanclub` (+ strikes/expulsions).
  /// **TEMP on** (CF-186 aba perfil + CF-222…230 + CF-223 Ver mais + CF-227 menu).
  /// Lista Moderadores também usa [kUseCf225ModeratorsMocks].
  /// Off quando API real bater os prints.
  static const useFanClubFixtures = true;

  /// Home feed — **TEMP on** (CF-232 vídeo + CF-233/234/235 + CF-236 share + CF-176 menu ⋯).
  /// Off quando `GET /api/v1/home` devolver posts equivalentes aos prints.
  static const useHomeFeedFixtures = true;

  /// Busca artistas (CF-240) — **off**: `GET /api/v1/search/artists`.
  /// Helpers [_cf240SearchArtistsPrint] / [cfTempMockSearchArtists] ficam
  /// só para testes de print. Não altera ranking (CF-172).
  static const useSearchArtistsFixtures = false;

  /// Seletor fã-clube compose — TEMP até follows/subs baterem o print CF-237.
  static const useFanClubSelectorFixtures = true;

  /// CF-239 Exclusivo liberado (Ludmilla) + CF-184 bloqueado (Kheper) —
  /// TEMP até subscriptions/check + posts exclusivos reais baterem os prints.
  /// Ludmilla → assinante; Kheper → teaser só (sem posts bloqueados).
  static const useArtistExclusiveFixtures = true;

  /// Painel moderação (CF-199) — **TEMP on**: fila Contestações 2 / Avisos 2 /
  /// Expulsos 1 (Anna Lu / Vic Melo) igual ao print. APIs de appeals/strikes/
  /// expulsions existem, mas sem dados de QA o painel fica vazio. Off quando
  /// seed/prod tiver fila real equivalente à referência.
  static const useModerationPanelFixtures = true;

  /// CF-198 Central de ajuda — **off**: conteúdo oficial em
  /// `lib/content/help_content.dart` (sem CMS). Flag dedicada:
  /// [kUseCf198HelpMocks] também false. Sample [Cf198HelpFixtures] só para
  /// asserts de print nos testes.
  static const useHelpFixtures = false;

  /// Prefs subpáginas CF-208/209/211 — preferences API.
  static const useNotificationCategoryPrintFixtures = false;

  /// CF-208 Interações com Você — **off**: API real
  /// `GET/PUT /api/v1/notifications/preferences`. Fixture class ainda espelha
  /// o print (5 switches off) para testes. Não liga hub CF-166 / CF-209/211/213.
  static const useInteractionsNotifPrintFixtures = false;

  /// CF-209 Meet & Greet — switches do print (convites/lembretes on, resultado off).
  /// TEMP até preferências reais baterem o estado de referência do QA.
  /// Não liga hub CF-166 nem CF-211 (wallet).
  static const useMeetGreetNotifPrintFixtures = true;

  /// CF-211 Membership e Jam Coins — switches do print (renovação/saldo on, promo off).
  /// TEMP até preferências reais baterem o estado de referência do QA.
  static const useMembershipNotifPrintFixtures = true;

  /// Hub Seu Perfil — `GET /api/v1/profile`.
  static const useProfileAccountFixtures = false;

  /// CF-187 Meu Perfil preenchido — TEMP até conta real bater o print.
  /// Flag dedicada: [kUseCf187MeProfileMocks].

  /// CF-185 perfil artista Feed — capa + CTA. Flag: [kUseCf185ArtistFeedMocks].

  /// Sobre Spotify/base — off após [CF-269] (campos reais no profile).
  static const useArtistSobreFixtures = false;

  /// Favoritos menu lateral CF-191 — **off**: favorites locais
  /// ([SidebarArtistsStore]) + “Seus Artistas” via follows (`GET /api/v1/follows`)
  /// / home. Helpers de print ficam para testes.
  static const useFavoriteArtistsFixtures = false;

  /// CF-191 — artistas do print (Favoritos + Seus Artistas).
  static List<HomeFollowedArtist> sidebarFollowedArtists({
    bool empty = false,
  }) {
    if (empty || kCf191MockEmpty) {
      return const [];
    }
    return const [
      HomeFollowedArtist(
        id: 'cf191-mayra',
        username: 'Mayra',
        avatarUrl: _avatarMayra,
      ),
      HomeFollowedArtist(
        id: 'cf191-marinhos',
        username: 'Marinhos',
        avatarUrl: _avatarMan,
      ),
      HomeFollowedArtist(
        id: 'cf191-uelo',
        username: 'Banda Uelo',
        avatarUrl: _avatarMeet,
      ),
      HomeFollowedArtist(
        id: 'cf191-enzo',
        username: 'Enzo Lima',
        avatarUrl: _avatarCamila,
      ),
      HomeFollowedArtist(
        id: 'cf191-ludmilla',
        username: 'Ludmilla',
        avatarUrl: _avatarWoman,
      ),
      HomeFollowedArtist(
        id: 'cf191-anitta',
        username: 'Anitta',
        avatarUrl: _avatarRed,
      ),
      HomeFollowedArtist(
        id: 'cf191-carol',
        username: 'Carol Biazin',
        avatarUrl: _avatarMayra,
      ),
      HomeFollowedArtist(
        id: 'cf191-kheper',
        username: 'Kheper',
        avatarUrl: _avatarMeet,
      ),
    ];
  }

  /// IDs favoritos do print CF-191 (estrelas amarelas).
  static Set<String> sidebarFavoriteIds({bool empty = false}) {
    if (empty || kCf191MockEmpty) {
      return {};
    }
    return {
      'cf191-mayra',
      'cf191-marinhos',
      'cf191-uelo',
    };
  }

  /// Visitado recentemente — print CF-191 sem linhas.
  static List<HomeFollowedArtist> sidebarRecentArtists({
    bool empty = false,
  }) {
    if (empty || kCf191MockEmpty) {
      return const [];
    }
    return const [];
  }

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

/// Amostra de linhas de ranking (print CF-189/193/241) para testes e, se a
/// flag [CfTempMocks.useRankingFixtures] estiver on, para UI TEMP.
/// Com CF-268 a API popula `weeksInRanking`/`peakRank`; flag fica off.
List<ArtistSearchItem> cfTempMockRankingArtists({
  required String kind,
  int limit = 8,
}) {
  final engaged = kind == 'engaged';
  final active = kind == 'active';
  // Avatares Unsplash — print usa fotos reais; vazio deixa bloco cinza.
  const avatars = <String>[
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=200&q=80',
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
    'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=200&q=80',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
    'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&q=80',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=200&q=80',
    'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=200&q=80',
    'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=200&q=80',
  ];
  String metaFor({
    required int members,
    required String membersLabel,
    required int posts,
    required int interactions,
  }) {
    if (engaged) {
      final n = interactions;
      return n == 1 ? '1 interação (7d)' : '$n interações (7d)';
    }
    if (active) {
      return '$posts posts (7d)';
    }
    return membersLabel;
  }

  // Interações 7d por id — CF-193: ordenação do Top 100 Engajados.
  const engagedInteractions = <String, int>{
    'mock-fc-ludmilla': 4,
    'mock-fc-anitta': 0,
    'mock-fc-mayra': 12,
    'mock-fc-uelo': 7,
    'mock-fc-carol': 3,
    'mock-fc-marinhos': 9,
    'mock-fc-enzo': 1,
    'mock-fc-tinn': 2,
  };

  final samples = <ArtistSearchItem>[
    // CF-241 print: sheet Ludmilla — semanas 11 / máx 1 / semana passada 2.
    ArtistSearchItem(
      id: 'mock-fc-ludmilla',
      name: 'Ludmilla',
      handle: '@ludmilla',
      avatarUri: avatars[0],
      memberCount: engaged ? 4 : 512000,
      membersLabel: metaFor(
        members: 512000,
        membersLabel: '512 mil membros',
        posts: 18,
        interactions: 4,
      ),
      rankingValueLabel: metaFor(
        members: 512000,
        membersLabel: '512 mil membros',
        posts: 18,
        interactions: 4,
      ),
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
      avatarUri: avatars[1],
      memberCount: engaged ? 0 : 487000,
      membersLabel: metaFor(
        members: 487000,
        membersLabel: '487 mil membros',
        posts: 14,
        interactions: 0,
      ),
      rankingValueLabel: metaFor(
        members: 487000,
        membersLabel: '487 mil membros',
        posts: 14,
        interactions: 0,
      ),
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
      avatarUri: avatars[2],
      memberCount: engaged ? 12 : 368000,
      membersLabel: metaFor(
        members: 368000,
        membersLabel: '368 mil membros',
        posts: 11,
        interactions: 12,
      ),
      rankingValueLabel: metaFor(
        members: 368000,
        membersLabel: '368 mil membros',
        posts: 11,
        interactions: 12,
      ),
      rank: 3,
      trend: 'neutral',
      rankDelta: 0,
      previousRank: 3,
      weeksInRanking: 8,
      peakRank: 2,
    ),
    ArtistSearchItem(
      id: 'mock-fc-uelo',
      name: 'Banda Uelo',
      handle: '@bandauelo',
      avatarUri: avatars[3],
      memberCount: engaged ? 7 : 228000,
      membersLabel: metaFor(
        members: 228000,
        membersLabel: '228 mil membros',
        posts: 9,
        interactions: 7,
      ),
      rankingValueLabel: metaFor(
        members: 228000,
        membersLabel: '228 mil membros',
        posts: 9,
        interactions: 7,
      ),
      rank: 4,
      trend: 'up',
      rankDelta: 2,
      previousRank: 6,
      weeksInRanking: 6,
      peakRank: 3,
    ),
    ArtistSearchItem(
      id: 'mock-fc-carol',
      name: 'Carol Biazin',
      handle: '@carolbiazin',
      avatarUri: avatars[4],
      memberCount: engaged ? 3 : 196000,
      membersLabel: metaFor(
        members: 196000,
        membersLabel: '196 mil membros',
        posts: 7,
        interactions: 3,
      ),
      rankingValueLabel: metaFor(
        members: 196000,
        membersLabel: '196 mil membros',
        posts: 7,
        interactions: 3,
      ),
      rank: 5,
      trend: 'down',
      rankDelta: 1,
      previousRank: 4,
      weeksInRanking: 4,
      peakRank: 5,
    ),
    ArtistSearchItem(
      id: 'mock-fc-marinhos',
      name: 'Marinhos',
      handle: '@marinhos',
      avatarUri: avatars[5],
      memberCount: engaged ? 9 : 537,
      membersLabel: metaFor(
        members: 537,
        membersLabel: '537 membros',
        posts: 4,
        interactions: 9,
      ),
      rankingValueLabel: metaFor(
        members: 537,
        membersLabel: '537 membros',
        posts: 4,
        interactions: 9,
      ),
      rank: 6,
      trend: 'neutral',
      rankDelta: 0,
      previousRank: 6,
      weeksInRanking: 2,
      peakRank: 6,
    ),
    ArtistSearchItem(
      id: 'mock-fc-enzo',
      name: 'Enzo Lima',
      handle: '@enzolima',
      avatarUri: avatars[6],
      memberCount: engaged ? 1 : 535,
      membersLabel: metaFor(
        members: 535,
        membersLabel: '535 membros',
        posts: 5,
        interactions: 1,
      ),
      rankingValueLabel: metaFor(
        members: 535,
        membersLabel: '535 membros',
        posts: 5,
        interactions: 1,
      ),
      rank: 7,
      trend: 'down',
      rankDelta: 2,
      previousRank: 5,
      weeksInRanking: 3,
      peakRank: 4,
    ),
    ArtistSearchItem(
      id: 'mock-fc-tinn',
      name: 'TINN',
      handle: '@tinn',
      avatarUri: avatars[7],
      memberCount: engaged ? 2 : 533,
      membersLabel: metaFor(
        members: 533,
        membersLabel: '533 membros',
        posts: 3,
        interactions: 2,
      ),
      rankingValueLabel: metaFor(
        members: 533,
        membersLabel: '533 membros',
        posts: 3,
        interactions: 2,
      ),
      rank: 8,
      trend: 'up',
      rankDelta: 1,
      previousRank: 9,
      weeksInRanking: 1,
      peakRank: 8,
    ),
  ];

  var ordered = samples;
  if (engaged) {
    final byInteractions = [...samples]
      ..sort((a, b) {
        final ia = engagedInteractions[a.id] ?? 0;
        final ib = engagedInteractions[b.id] ?? 0;
        return ib.compareTo(ia);
      });
    ordered = [
      for (var i = 0; i < byInteractions.length; i++)
        ArtistSearchItem(
          id: byInteractions[i].id,
          name: byInteractions[i].name,
          handle: byInteractions[i].handle,
          avatarUri: byInteractions[i].avatarUri,
          memberCount: byInteractions[i].memberCount,
          membersLabel: byInteractions[i].membersLabel,
          rankingValueLabel: byInteractions[i].rankingValueLabel,
          rank: i + 1,
          trend: byInteractions[i].trend,
          rankDelta: byInteractions[i].rankDelta,
          previousRank: byInteractions[i].previousRank,
          weeksInRanking: byInteractions[i].weeksInRanking,
          peakRank: byInteractions[i].peakRank,
        ),
    ];
  }

  if (limit >= ordered.length) {
    return List<ArtistSearchItem>.from(ordered);
  }
  return ordered.take(limit).toList(growable: false);
}

/// CF-229 — banner expulso (Felipe Rhy) no feed do clube.
/// TEMP até a conta de QA receber `viewerIsExpelled` + motivo da API.
/// Complementa [CfTempMocks.useFanClubFixtures] (atalho Clubes + cover).
const bool kUseCf229ExpelledFixtures = true;

/// Cover do print CF-229 (mic / spotlight).
const cfTempMockFelipeCoverUrl =
    'https://images.unsplash.com/photo-1516280440612-596598c2f5a2?auto=format&fit=crop&w=1200&q=80';

/// ArtistUid do print CF-229 para atalho em Clubes.
const cfTempMockFelipeArtistUid = 'mock-fc-felipe-rhy';

/// Motivo de expulsão para Defender retorno (CF-200 / CF-229) quando a API não manda.
const cfTempMockExpulsionReason =
    'A equipe identificou ataques recorrentes e quebra das regras de convivência do fã clube.';

/// CF-200 — tela Defender retorno (motivo rosado + campo 24–420).
/// TEMP até a API sempre enviar `viewerExpulsionReason` e o submit real
/// funcionar na conta de QA. Não altera flags CF-229/CF-230.
const bool kUseCf200DefendReturnFixtures = true;

/// True quando o mock TEMP da tela Defender retorno (CF-200) está ativo.
bool cf200DefendReturnFixturesEnabled() =>
    kUseCfTempMocks && kUseCf200DefendReturnFixtures;

/// Motivo de aviso de moderação (CF-230).
const cfTempMockStrikeReason =
    'Você insistiu em provocações repetidas nos comentários mesmo depois de avisos da equipe.';

/// True quando o mock TEMP do banner expulso (CF-229) está ativo.
bool cf229ExpelledFixturesEnabled() =>
    kUseCfTempMocks && kUseCf229ExpelledFixtures;

/// CF-230 — banner aviso (Laís Costa) no feed do clube.
/// TEMP até a conta de QA receber strikes + motivo + chances da API.
/// Não altera o caminho expulso (CF-229).
const bool kUseCf230WarningFixtures = true;

/// CF-227 — menu do post no fã-clube (print Lari Rocha / Laís Costa).
/// TEMP até o feed real do clube expor o post do print; reutiliza a variante
/// warning ([cfTempMockLaisArtistUid]) e o atalho Clubes do CF-230.
const bool kUseCf227FanClubPostMenuFixtures = true;

/// Cover do print CF-230 (Laís Costa).
const cfTempMockLaisCoverUrl =
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=1200&q=80';

/// ArtistUid do print CF-227 / CF-230 para atalho em Clubes.
const cfTempMockLaisArtistUid = 'mock-fc-lais';

/// Avatar do post Lari Rocha no print CF-230 / CF-227.
const cfTempMockLariAvatarUrl =
    'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?auto=format&fit=crop&w=200&q=80';

/// True quando o mock TEMP do banner de aviso (CF-230) está ativo.
bool cf230WarningFixturesEnabled() =>
    kUseCfTempMocks && kUseCf230WarningFixtures;

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

/// Resumo de membership para Assinar (CF-206) e confirmação (CF-207).
/// CF-207 deep-link vazio: [CfTempMocks.useMembershipActivationConfirmedFixtures].
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

/// Recarga confirmada (CF-204) — referência do print (240 = 200 JC + 40 bônus).
/// A tela de confirmação usa só params da transação real; este mock é TEMP
/// para testes/QA deep-link, não é inventado na UI.
const cfTempMockRechargeConfirmed = (
  coinsTotal: 240,
  baseCoins: 200,
  bonusCoins: 40,
);

/// Copy da seção “O que entra na conta” (print CF-202; corpo cortado no anexo).
const cfTempMockFanScoreHowItWorksFactorsBody =
    'Curtidas, comentários, cartas, membership, doações e '
    'presença no fã-clube entram na pontuação do ciclo. '
    'Interações com o próprio artista pesam mais.';

/// FanScore demo do print CF-201 (ciclo + cards Ultimate/Super).
/// CF-202 reutiliza [cycleDetails.endLabel] no rodapé “Como funciona”.
FanScoreData cfTempMockFanScoreData() {
  // Print: badge Ultimate lilás claro + texto roxo escuro; Super dourado.
  const ultimate = FanScoreTier(
    id: 'ultimate',
    label: 'Ultimate Fan',
    minScore: 900,
    gradient: ['#EDE9FE', '#E9D5FF'],
    badgeGradient: ['#DDD6FE', '#C4B5FD'],
    badgeText: '#4C1D95',
    border: '#C4B5FD',
  );
  const superFan = FanScoreTier(
    id: 'super',
    label: 'Super Fan',
    minScore: 500,
    gradient: ['#FFF7E0', '#FFE8B0'],
    badgeGradient: ['#FDC55F', '#F5B942'],
    badgeText: '#FFFFFF',
    border: '#F6D58A',
  );
  const superFanAlt = FanScoreTier(
    id: 'super',
    label: 'Super Fan',
    minScore: 500,
    gradient: ['#FFF8E7', '#FFE9B5'],
    badgeGradient: ['#FDC55F', '#F5B942'],
    badgeText: '#FFFFFF',
    border: '#F6D58A',
  );
  return const FanScoreData(
    cycleDetails: FanScoreCycleDetails(
      periodLabel: 'Agosto 2026',
      cycleLabel: 'Agosto 2026',
      endLabel: 'segunda-feira, 31/08/2026 às 23:59',
      helperText:
          'O ciclo vigente encerra em segunda-feira, 31/08/2026 às 23:59 e reseta logo em seguida.',
    ),    entries: [
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
/// **Off:** `GET /api/v1/posts/:postId/comments` (replies aninhadas) — fixtures
/// ficam só para testes de print.
const bool kUseCf194CommentMocks = false;

/// Dados do print CF-194 (recolhido = image1 / expandido = image.png).
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
  static const ninaHandle = 'fan/ninacosta';

  static List<CommentItem> comments() {
    final reply = CommentItem(
      id: 'cf194-reply-1',
      author: 'Rafa Nogueira',
      handle: 'fan/rafanogueira',
      avatarUri: '',
      minutesAgo: 120,
      text: 'Esse tipo de conteúdo sempre rende discussão boa.',
      votes: 15,
      parentCommentId: 'cf194-c1',
    );
    final ninaReplyA = CommentItem(
      id: 'cf194-reply-2a',
      author: 'Lia Costa',
      handle: 'fan/liacosta',
      avatarUri: '',
      minutesAgo: 150,
      text: 'Exato — o feed trouxe e o fio manteve.',
      votes: 6,
      parentCommentId: 'cf194-c2',
    );
    final ninaReplyB = CommentItem(
      id: 'cf194-reply-2b',
      author: 'Bruno M.',
      handle: 'fan/brunom',
      avatarUri: '',
      minutesAgo: 90,
      text: 'Salvei esse thread inteiro.',
      votes: 3,
      parentCommentId: 'cf194-c2',
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
      CommentItem(
        id: 'cf194-c2',
        author: 'Nina Costa',
        handle: ninaHandle,
        avatarUri: '',
        minutesAgo: 180,
        text:
            'Cheguei pelo feed e fiquei pelos comentários. Era exatamente esse efeito que eu queria ver nos testes.',
        votes: 212,
        replies: [ninaReplyA, ninaReplyB],
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

/// CF-185 — Perfil artista Feed (prints capa + Seguir / Membership♪ / ✓).
/// TEMP até photoUrl/membros/follow reais baterem a referência. Não altera
/// a aba Fã Clube (CF-186).
const bool kUseCf185ArtistFeedMocks = true;

/// Fixture do print CF-185 (capa fotográfica + estados de CTA separados).
final class Cf185ArtistFeedFixture {
  const Cf185ArtistFeedFixture({
    required this.displayName,
    required this.handle,
    required this.coverUrl,
    required this.memberCount,
    required this.rank,
    required this.feedPosts,
    this.following,
    this.subscribed,
  });

  final String displayName;
  final String handle;
  final String coverUrl;
  final int memberCount;
  final int rank;
  final List<FeedPost> feedPosts;

  /// null = não sobrescrever follow da API / outros mocks.
  final bool? following;

  /// null = não sobrescrever assinatura (ex.: CF-239 Ludmilla).
  final bool? subscribed;
}

/// Prints CF-185: Ludmilla (+capa), Laís (+Seguir→Membership♪), Mayra (✓).
abstract final class Cf185ArtistFeedFixtures {
  static const _coverStage =
      'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?auto=format&fit=crop&w=1200&q=80';
  static const _coverMic =
      'https://images.unsplash.com/photo-1516280440612-596598c2f5a2?auto=format&fit=crop&w=1200&q=80';
  static const _aerialCity =
      'https://images.unsplash.com/photo-1477959858617-67f85b34b5df?auto=format&fit=crop&w=800&q=80';

  static Cf185ArtistFeedFixture? resolve(String artistId, String? name) {
    final id = artistId.trim().toLowerCase();
    final n = (name ?? '').trim().toLowerCase();
    if (id.contains('ludmilla') ||
        id == 'mock-fc-ludmilla' ||
        n.contains('ludmilla')) {
      return ludmilla();
    }
    if (id.contains('lais') ||
        id.contains('laís') ||
        id == 'mock-fc-lais' ||
        n.contains('laís') ||
        n.contains('lais')) {
      return lais();
    }
    if (id.contains('mayra') || id == 'mock-fc-mayra' || n.contains('mayra')) {
      return mayra();
    }
    return null;
  }

  /// image.png — capa foto + membros; CTA Seguir fica nos testes / Laís.
  /// Não força follow/sub (CF-239 pode marcar Ludmilla assinante).
  static Cf185ArtistFeedFixture ludmilla() {
    return const Cf185ArtistFeedFixture(
      displayName: 'Ludmilla',
      handle: '@ludmilla',
      coverUrl: _coverStage,
      memberCount: 512000,
      rank: 2,
      feedPosts: [
        FeedPost(
          id: 'cf185-lud-feed-1',
          type: PostType.image,
          author: 'Ludmilla',
          artistId: 'mock-fc-ludmilla',
          handle: '@ludmilla',
          minutesAgo: 25,
          avatarUri: _coverStage,
          text:
              'Hoje foi estúdio, prova de look e conversa longa com a equipe. Resolvi largar tudo aqui.',
          votes: 123,
          comments: 26,
          shares: 9,
          imageUri: _cfCarouselDeer,
        ),
      ],
    );
  }

  /// image1 (+ Seguir) → tap → image2 (Membership ♪).
  static Cf185ArtistFeedFixture lais() {
    return const Cf185ArtistFeedFixture(
      displayName: 'Laís Costa',
      handle: '@laiscosta',
      coverUrl: _coverMic,
      memberCount: 215,
      rank: 4,
      following: false,
      subscribed: false,
      feedPosts: [
        FeedPost(
          id: 'cf185-lais-feed-1',
          type: PostType.carousel,
          author: 'Laís Costa',
          artistId: 'mock-fc-lais',
          handle: '@laiscosta',
          minutesAgo: 51,
          avatarUri: _coverMic,
          text:
              'Dump de backstage, café e conversa. O tipo de sequência que eu amo guardar.',
          votes: 96,
          comments: 14,
          shares: 5,
          imageUri: _aerialCity,
          carouselUris: [_aerialCity, _cfCarouselCity],
        ),
      ],
    );
  }

  /// image3 — Membership ✓.
  static Cf185ArtistFeedFixture mayra() {
    return const Cf185ArtistFeedFixture(
      displayName: 'Mayra',
      handle: '@mayra',
      coverUrl: _coverMic,
      memberCount: 368000,
      rank: 3,
      following: true,
      subscribed: true,
      feedPosts: [
        FeedPost(
          id: 'cf185-mayra-feed-1',
          type: PostType.text,
          author: 'Mayra',
          artistId: 'mock-fc-mayra',
          handle: '@mayra',
          minutesAgo: 8,
          avatarUri: _coverMic,
          text:
              'Cada vez que vocês puxam teoria nova eu volto pro bloco de notas. Já tem música nascendo daí.',
          votes: 84,
          comments: 11,
          shares: 3,
        ),
        FeedPost(
          id: 'cf185-mayra-feed-2',
          type: PostType.text,
          author: 'Mayra',
          artistId: 'mock-fc-mayra',
          handle: '@mayra',
          minutesAgo: 120,
          avatarUri: _coverMic,
          text:
              'Dia de foto, roteiro, reunião e muita vontade de postar tudo de uma vez',
          votes: 41,
          comments: 6,
          shares: 2,
        ),
      ],
    );
  }
}

/// CF-187 — Meu Perfil preenchido (print image.png). TEMP para homologar
/// seletor + contagens/bio/posts quando a conta real ainda está vazia.
const bool kUseCf187MeProfileMocks = true;

/// CF-225 — lista Moderadores (print Enzo Lima + 3 fãs). TEMP até
/// `GET …/fanclub` devolver moderadores com nome/handle/avatar do print.
/// Flag dedicada na tela; [CfTempMocks.useFanClubFixtures] já cobre o feed.
const bool kUseCf225ModeratorsMocks = true;

/// CF-224 — Solicitar moderação (candidato Aline + limites 24/420). TEMP
/// até o perfil real bater o print; não altera CF-225 lista / CF-199 painel.
const bool kUseCf224RequestModerationMocks = true;

/// Fixtures do print CF-187 (Aline Duarte + filtro + posts).
abstract final class Cf187MeProfileFixtures {
  static const _avatar =
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=200&q=80';

  static const Profile profile = Profile(
    userUid: 'cf187-aline',
    displayName: 'Aline Duarte',
    name: 'alineduarte',
    description:
        'Gosto muito di rock e pop, se vouse gosta tambem vamos ser amigass... Agora nao me venha com sertanejo, asho insuportavel rs',
    photoUrl: _avatar,
    isArtist: false,
    stats: ProfileStats(
      postsCount: 1180,
      cartasCount: 124,
      artistasCount: 8,
    ),
  );

  static List<FollowedArtist> followedArtists() {
    return const [
      FollowedArtist(
        id: 'mock-fc-mayra',
        label: 'Mayra',
        memberCount: '12840',
        avatarUri: '',
      ),
      FollowedArtist(
        id: 'mock-fc-lais',
        label: 'Laís Costa',
        memberCount: '8225',
        avatarUri: '',
      ),
      FollowedArtist(
        id: 'mock-fc-marinhos',
        label: 'Marinhos',
        memberCount: '5400',
        avatarUri: '',
      ),
    ];
  }

  static List<FeedPost> posts() {
    return const [
      FeedPost(
        id: 'cf187-post-mutirao',
        type: PostType.text,
        author: 'Aline Duarte',
        artistId: 'mock-fc-mayra',
        handle: 'fan/alineduarte',
        minutesAgo: 6,
        avatarUri: _avatar,
        text:
            'Thread oficial do mutirão de engajamento — quem puder comentar e compartilhar já ajuda o ranking da semana.',
        votes: 96,
        comments: 14,
        shares: 5,
        isSecret: true,
        membershipBadges: [MembershipBadgeInfo(label: '3')],
      ),
      FeedPost(
        id: 'cf187-post-backstage',
        type: PostType.text,
        author: 'Aline Duarte',
        artistId: 'mock-fc-lais',
        handle: 'fan/alineduarte',
        minutesAgo: 11,
        avatarUri: _avatar,
        text:
            'Fotinho do backstage depois do soundcheck. Sem sertanejo no setlist, graças a deus.',
        votes: 96,
        comments: 14,
        shares: 5,
        isSecret: true,
        membershipBadges: [MembershipBadgeInfo(label: '3')],
      ),
    ];
  }
}

/// CF-216 — fixtures do print (3 aparelhos). **Off:** API CF-266
/// `GET/POST/DELETE /api/v1/me/sessions` (FE: [UserSessionService]).
const bool kUseCf216ConnectedDevicesMocks = false;

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

/// CF-219 — bio do print (contador 56).
abstract final class Cf219EditBioMock {
  static const bio =
      'Gosto muito di rock e pop, se vc gosta tb vamos ser ami!';
}

/// Liga dados de demo do CF-195 (Home sem comentários → print populado).
/// **Off:** comments API real; fixtures só para testes de print.
const bool kUseCf195CommentMocks = false;

/// Liga fixtures do seletor de GIF (CF-197) — evita Tenor/API key em QA.
/// Desligar quando `TENOR_API_KEY` de prod estiver estável no app.
const bool kUseCf197GifMocks = true;

/// GIFs demo do sheet Escolher GIF (featured / busca / vazio).
abstract final class Cf197GifFixtures {
  static const _thumbA =
      'https://images.unsplash.com/photo-1516280440612-596598c2f5a2?auto=format&fit=crop&w=200&q=80';
  static const _thumbB =
      'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?auto=format&fit=crop&w=200&q=80';
  static const _thumbC =
      'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?auto=format&fit=crop&w=200&q=80';
  static const _thumbD =
      'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=200&q=80';
  static const _thumbE =
      'https://images.unsplash.com/photo-1484406566174-9da000fda645?auto=format&fit=crop&w=200&q=80';
  static const _thumbF =
      'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?auto=format&fit=crop&w=200&q=80';

  static List<CommentGifItem> featured() {
    return const [
      CommentGifItem(
        id: 'cf197-feat-1',
        previewUrl: _thumbA,
        originalUrl: _thumbA,
        label: 'Microfone no palco',
      ),
      CommentGifItem(
        id: 'cf197-feat-2',
        previewUrl: _thumbB,
        originalUrl: _thumbB,
        label: 'Show ao vivo',
      ),
      CommentGifItem(
        id: 'cf197-feat-3',
        previewUrl: _thumbC,
        originalUrl: _thumbC,
        label: 'Luzes de festival',
      ),
      CommentGifItem(
        id: 'cf197-feat-4',
        previewUrl: _thumbD,
        originalUrl: _thumbD,
        label: 'Praia ao entardecer',
      ),
      CommentGifItem(
        id: 'cf197-feat-5',
        previewUrl: _thumbE,
        originalUrl: _thumbE,
        label: 'Cervo na floresta',
      ),
      CommentGifItem(
        id: 'cf197-feat-6',
        previewUrl: _thumbF,
        originalUrl: _thumbF,
        label: 'Cidade à noite',
      ),
    ];
  }

  /// Featured (query vazia), busca filtrada, ou lista vazia.
  static List<CommentGifItem> itemsFor(String query) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) {
      return featured();
    }
    if (trimmed.contains('___sem_resultado___') ||
        trimmed == 'xyzzy' ||
        trimmed == 'semresultado') {
      return const [];
    }
    final all = featured();
    final matched = [
      for (final item in all)
        if ((item.label ?? '').toLowerCase().contains(trimmed) ||
            item.id.toLowerCase().contains(trimmed))
          item,
    ];
    if (matched.isNotEmpty) {
      return matched;
    }
    // Busca genérica (ex.: "rock") → subset demo com ids marcados.
    return [
      for (var i = 0; i < all.length && i < 3; i++)
        CommentGifItem(
          id: 'cf197-rock-${all[i].id}',
          previewUrl: all[i].previewUrl,
          originalUrl: all[i].originalUrl,
          label: all[i].label,
        ),
    ];
  }
}


/// Print CF-195: só a 1ª thread com respostas começa expandida.


/// Print CF-195: só a 1ª thread com respostas começa expandida.
Set<String> cf195InitialExpandedReplyIds(List<CommentItem> comments) {
  for (final comment in comments) {
    if (comment.replies.isNotEmpty) {
      return {comment.id};
    }
  }
  return {};
}

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
      minutesAgo: 120,
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
        author: 'Nina Costa',
        handle: 'fan/ninacosta',
        avatarUri: '',
        minutesAgo: 180,
        text:
            'Cheguei pelo feed e fiquei pelos comentários. Era exatamente esse efeito que eu queria ver nos testes.',
        votes: 212,
        replies: [collapsedA, collapsedB],
      ),
      CommentItem(
        id: 'cf195-c3',
        author: 'Vic Melo',
        handle: 'fan/vicmelo',
        avatarUri: '',
        minutesAgo: 180,
        text: 'Alguém mais salvou esse post?',
        votes: 18,
      ),
    ];
  }
}

/// Liga demo CF-196 (resposta + teclado). **Off:** compositor nativo cobre
/// banner/prefill/insets; helpers ficam para testes green/red/edge.
/// Não altera listas CF-194/195 — só metadados do compositor de resposta.
const bool kUseCf196CommentMocks = false;

/// Print CF-196: Respondendo a Rafa + `fan/rafanogueira` + teclado.
abstract final class Cf196CommentReplyMock {
  static const replyAuthor = 'Rafa Nogueira';
  static const replyHandle = 'fan/rafanogueira';

  /// Inset aproximado do teclado iOS nos anexos (compositor acima).
  static const keyboardInset = 280.0;

  /// Prefill `fan/...` no campo (print image.png).
  static String mentionDraft(String? handle) {
    final raw = (handle ?? '').trim();
    if (raw.isEmpty) {
      return '';
    }
    if (raw.startsWith('fan/') || raw.startsWith('@')) {
      return '$raw ';
    }
    return 'fan/$raw ';
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
/// Print CF-233 slide 1 — silhuetas em quadra / golden hour.
const _cfCarouselCourtSunset =
    'https://images.unsplash.com/photo-1546519638-68e109498ffc?auto=format&fit=crop&w=800&q=80';
/// Print CF-233 slide 2 — praia com guarda-sóis.
const _cfCarouselBeachUmbrellas =
    'https://images.unsplash.com/photo-1473116763249-2faaef81ccda?auto=format&fit=crop&w=800&q=80';

/// Cover do print CF-222 (cadeira / interior).
const cfTempMockFanClubCoverUrl =
    'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?auto=format&fit=crop&w=1200&q=80';

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
  // Avatares alinhados ao print CF-225 (Aline / Maria / Lari+gato).
  return const [
    FanClubModerator(
      userUid: 'cf-mod-aline',
      handle: 'alineduarte',
      displayName: 'Aline Duarte',
      photoUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=100&q=80',
      role: 'moderator',
    ),
    FanClubModerator(
      userUid: 'cf-mod-maria',
      handle: 'mariaeduarda',
      displayName: 'Maria Eduarda',
      photoUrl:
          'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?auto=format&fit=crop&w=100&q=80',
      role: 'moderator',
    ),
    FanClubModerator(
      userUid: 'cf-mod-lari',
      handle: 'larirocha',
      displayName: 'Lari Rocha',
      photoUrl:
          'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?auto=format&fit=crop&w=100&q=80',
      role: 'moderator',
    ),
  ];
}

/// CF-186 — aba Fã Clube no perfil do artista (print Ludmilla: Carina + Pedro).
bool cfTempMockIsLudmillaFanClubTab(String artistUid) {
  final id = artistUid.trim().toLowerCase();
  return id.contains('ludmilla') || id == 'mock-fc-ludmilla';
}

const _cf186AvatarCarina =
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=100&q=80';
const _cf186AvatarPedro =
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=100&q=80';

List<FanClubFeedPost> cfTempMockLudmillaFanClubTabPosts() {
  final twoHoursAgo = DateTime.now()
      .subtract(const Duration(hours: 2))
      .toIso8601String();
  return [
    FanClubFeedPost(
      postId: 'cf186-carina-video',
      content:
          'Trecho curto da reação do setor inteiro quando a intro mudou ao vivo.',
      createdAt: twoHoursAgo,
      type: 'video',
      imageUrl: '',
      likesCount: 875,
      commentsCount: 25,
      sharesCount: 8,
      authorName: 'Carina Silva',
      authorHandle: 'fan/carinas',
      authorAvatarUri: _cf186AvatarCarina,
    ),
    FanClubFeedPost(
      postId: 'cf186-pedro-text',
      content:
          'Quem topa grupo só pra trocar conteúdo e organizar presença nos próximos shows?',
      createdAt: twoHoursAgo,
      type: 'text',
      likesCount: 916,
      commentsCount: 36,
      sharesCount: 11,
      authorName: 'Pedro Martins',
      authorHandle: 'fan/pedrom',
      authorAvatarUri: _cf186AvatarPedro,
      membershipMonthsLabel: '6',
    ),
  ];
}

ArtistFanClub _cfTempMockLudmillaFanClubMeta(String artistUid) {
  return ArtistFanClub(
    id: 186,
    name: 'Ludmilla Fã Clube',
    description: 'Fã clube de Ludmilla',
    artistUid: artistUid.trim().isEmpty ? 'mock-fc-ludmilla' : artistUid,
    artistName: 'Ludmilla',
    isActive: true,
    memberCount: 18420,
    isMember: true,
    moderators: cfTempMockFanClubModerators(),
  );
}

/// Feed do fã-clube alinhado aos prints CF-186 / 222 / 227 / 229 / 230.
ArtistFanClubFeed cfTempMockArtistFanClubFeed(
  String artistUid, {
  int page = 1,
}) {
  // CF-186: perfil Ludmilla → posts da comunidade do print (não Enzo).
  if (cfTempMockIsLudmillaFanClubTab(artistUid)) {
    final club = _cfTempMockLudmillaFanClubMeta(artistUid);
    if (page > 1) {
      return ArtistFanClubFeed(fanClub: club, posts: const []);
    }
    return ArtistFanClubFeed(
      fanClub: club,
      posts: cfTempMockLudmillaFanClubTabPosts(),
    );
  }
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
    // CF-227 menu do post + CF-230 aviso: post Lari Rocha (cidade / BH).
    CfFanClubFixtureKind.warning => [
      FanClubFeedPost(
        postId: 'cf227-lari-bh',
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
        authorAvatarUri: cfTempMockLariAvatarUrl,
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
      name: 'Laís Costa',
      description: 'Fã clube de Laís Costa',
      artistUid: artistUid.trim().isEmpty ? cfTempMockLaisArtistUid : artistUid,
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
  photoUrl:
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=100&q=80',
);

/// URIs do visualizador CF-234 (print: cervo como `1/3`).
List<String> cfTempMockCf234LightboxUris() {
  return const [_cfCarouselDeer, _cfCarouselBeach, _cfCarouselCity];
}

/// Post de fundo do print CF-236 (Mayra texto · 84 / 11 / 3) — abre share sheet.
FeedPost cfTempMockCf236SharePost() {
  return const FeedPost(
    id: 'cf236-mayra-share',
    type: PostType.text,
    author: 'Mayra',
    artistId: 'mock-fc-mayra',
    handle: '@mayra',
    rank: '#3',
    minutesAgo: 8,
    avatarUri: '',
    text:
        'Ensaio curto antes do show. Queria deixar registrado aqui com vocês.',
    votes: 84,
    comments: 11,
    shares: 3,
  );
}

/// CF-176 — menu ⋯ do post (home). TEMP até o feed real expor post com artista
/// para abrir `PostOptionsSheet` igual ao print (atalhos + share + lista + Reportar).
const bool kUseCf176PostOptionsMocks = true;

/// Post dedicado do print CF-176 (Carol) — abre o menu de gerenciamento via ⋯.
FeedPost cfTempMockCf176MenuPost() {
  return const FeedPost(
    id: 'cf176-menu-post',
    type: PostType.text,
    author: 'Carol Biazin',
    artistId: 'mock-fc-carol',
    handle: '@carolbiazin',
    rank: '#12',
    minutesAgo: 22,
    avatarUri: '',
    text:
        'Obrigada por cada mensagem depois do último post. Vocês deixam tudo mais leve aqui.',
    votes: 98,
    comments: 12,
    shares: 4,
  );
}

/// Home feed — vídeo / carrossel / exclusivo / share (CF-232 / 233 / 235 / 236 / 175 / 176).
/// Ordem do print CF-235: Mayra exclusivo primeiro; Uelo parcial abaixo.
/// CF-175: Kheper exclusivo bloqueado (CTA contornado) após Mayra.
/// CF-236: Mayra texto 84/11/3 (tap share → sheet distinto do menu ⋯).
/// CF-176: Carol texto — tap ⋯ → `PostOptionsSheet` (gestão, não share).
/// CF-234 abre o lightbox a partir do carrossel (≥3 URIs).
List<FeedPost> cfTempMockHomeFeedPosts() {
  return [
    const FeedPost(
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
    const FeedPost(
      id: 'cf175-kheper-locked',
      type: PostType.text,
      author: 'Kheper',
      artistId: 'mock-fc-kheper',
      handle: '@kheperrrr',
      minutesAgo: 19,
      avatarUri: '',
      text: '',
      votes: 110,
      comments: 21,
      shares: 7,
      isExclusive: true,
      exclusiveLocked: true,
    ),
    cfTempMockCf236SharePost(),
    if (kUseCfTempMocks && kUseCf176PostOptionsMocks) cfTempMockCf176MenuPost(),
    const FeedPost(
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
    const FeedPost(
      id: 'cf233-ponzanelli-carousel',
      type: PostType.carousel,
      author: 'Ponzanelli',
      artistId: 'mock-fc-ponzanelli',
      handle: '@ponzanelli',
      minutesAgo: 60,
      avatarUri: '',
      text:
          'Momentos do backstage que normalmente não entram em lugar nenhum. Agora entraram.',
      votes: 240,
      comments: 36,
      shares: 7,
      imageUri: _cfCarouselCourtSunset,
      // Print CF-233 (quadra → guarda-sóis → deer). Lightbox CF-234 usa
      // [cfTempMockCf234LightboxUris] (deer-first) nos testes próprios.
      carouselUris: [
        _cfCarouselCourtSunset,
        _cfCarouselBeachUmbrellas,
        _cfCarouselDeer,
      ],
    ),
    const FeedPost(
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

/// Seletor Novo post → Fã Clube (CF-237) — ordem e nomes do print.
List<FanClubComposeArtist> cfTempMockFanClubSelectorArtists() {
  const mayra =
      'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=100&q=80';
  const marinhos =
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=100&q=80';
  const uelo =
      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=100&q=80';
  const enzo =
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=100&q=80';
  const ludmilla =
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=100&q=80';
  const anitta =
      'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=100&q=80';
  return const [
    FanClubComposeArtist(
      id: 'mock-fc-mayra',
      name: 'Mayra',
      avatarUrl: mayra,
    ),
    FanClubComposeArtist(
      id: 'mock-fc-marinhos',
      name: 'Marinhos',
      avatarUrl: marinhos,
    ),
    FanClubComposeArtist(
      id: 'mock-fc-uelo',
      name: 'Banda Uelo',
      avatarUrl: uelo,
    ),
    FanClubComposeArtist(
      id: 'mock-fc-enzo',
      name: 'Enzo Lima',
      avatarUrl: enzo,
    ),
    FanClubComposeArtist(
      id: 'mock-fc-ludmilla',
      name: 'Ludmilla',
      avatarUrl: ludmilla,
    ),
    FanClubComposeArtist(
      id: 'mock-fc-anitta',
      name: 'Anitta',
      avatarUrl: anitta,
    ),
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

/// Exclusivo bloqueado no perfil (CF-184) — Kheper / print sem assinatura.
/// Nunca inclui Ludmilla (caminho CF-239 unlocked).
bool cfTempMockArtistExclusiveForceLocked(String artistId, String? name) {
  if (cfTempMockArtistExclusiveSubscribed(artistId, name)) {
    return false;
  }
  final id = artistId.trim().toLowerCase();
  final n = (name ?? '').trim().toLowerCase();
  return id.contains('kheper') || n.contains('kheper');
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

/// Resultados print CF-240 (Buscar artistas · query “L”).
List<ArtistSearchItem> _cf240SearchArtistsPrint() {
  return const [
    ArtistSearchItem(
      id: 'mock-search-ludmilla',
      name: 'Ludmilla',
      handle: '@ludmilla',
      avatarUri: '',
      memberCount: 512000,
      membersLabel: '512 mil membros',
      rank: 1,
    ),
    ArtistSearchItem(
      id: 'mock-search-anitta',
      name: 'Anitta',
      handle: '@anitta',
      avatarUri: '',
      memberCount: 487000,
      membersLabel: '487 mil membros',
      rank: 2,
    ),
    ArtistSearchItem(
      id: 'mock-search-mayra',
      name: 'Mayra',
      handle: '@mayra',
      avatarUri: '',
      memberCount: 368000,
      membersLabel: '368 mil membros',
      rank: 3,
    ),
    ArtistSearchItem(
      id: 'mock-search-uelo',
      name: 'Banda Uelo',
      handle: '@bandauelo',
      avatarUri: '',
      memberCount: 228000,
      membersLabel: '228 mil membros',
      rank: 4,
    ),
    ArtistSearchItem(
      id: 'mock-search-carol',
      name: 'Carol Biazin',
      handle: '@carolbiazin',
      avatarUri: '',
      memberCount: 196000,
      membersLabel: '196 mil membros',
      rank: 5,
    ),
  ];
}

/// Busca artistas “L” (CF-240). Lista própria — não reusa ranking (CF-172/241).
List<ArtistSearchItem>? cfTempMockSearchArtists(String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) {
    return null;
  }
  final all = _cf240SearchArtistsPrint();
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
/// Desligado: `GET /api/v1/community/posts`.
const bool kUseCf178FanClubsFeedMocks = false;

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
/// Off só com `GET /api/v1/fan-letters/artist/:artistId` equivalente ao print.
const bool kUseCf181CartasMocks = true;

/// Cartas do print CF-181 (image4/image5 — autoria topo + grade 3 colunas).
abstract final class Cf181CartasMock {
  static const _avatarAline =
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=100&q=80';
  static const _avatarMaria =
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=100&q=80';
  static const _avatarCaio =
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=100&q=80';
  static const _avatarJoao =
      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=100&q=80';
  static const _avatarAnna =
      'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=100&q=80';
  static const _avatarLia =
      'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=100&q=80';
  static const _avatarRafa =
      'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=100&q=80';
  static const _avatarVic =
      'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=100&q=80';

  static List<FanLetter> letters({required String artistId}) {
    return [
      FanLetter(
        id: 'cf181-1',
        artistId: artistId,
        artistName: 'Ludmilla',
        fanDisplayName: 'Aline Duarte',
        fanHandle: 'alineduarte',
        fanAvatarUri: _avatarAline,
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
        fanDisplayName: 'Aline Duarte',
        fanHandle: 'alineduarte',
        fanAvatarUri: _avatarAline,
        votesCount: 11,
        sendsCount: 1,
        artistUpvoted: false,
        postedAt: 0,
        bodyText: 'LUDMILLA',
        backgroundId: 'grad-lilac',
      ),
      FanLetter(
        id: 'cf181-3',
        artistId: artistId,
        artistName: 'Ludmilla',
        fanDisplayName: 'Maria Eduarda',
        fanHandle: 'mariaeduarda',
        fanAvatarUri: _avatarMaria,
        votesCount: 9,
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
        fanDisplayName: 'Caio Loux',
        fanHandle: 'caioloux',
        fanAvatarUri: _avatarCaio,
        votesCount: 8,
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
        fanDisplayName: 'João Ribeiro',
        fanHandle: 'joaoribeiro',
        fanAvatarUri: _avatarJoao,
        votesCount: 7,
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
        fanDisplayName: 'Anna Lu',
        fanHandle: 'annalu',
        fanAvatarUri: _avatarAnna,
        votesCount: 6,
        sendsCount: 1,
        artistUpvoted: false,
        postedAt: 0,
        bodyText: 'MEU CONFORTO',
        backgroundId: 'grad-peach',
      ),
      FanLetter(
        id: 'cf181-7',
        artistId: artistId,
        artistName: 'Ludmilla',
        fanDisplayName: 'Lia Costa',
        fanHandle: 'liacosta',
        fanAvatarUri: _avatarLia,
        votesCount: 5,
        sendsCount: 1,
        artistUpvoted: false,
        postedAt: 0,
        bodyText: 'CARTA ABERTA',
        backgroundId: 'grad-mint',
      ),
      FanLetter(
        id: 'cf181-8',
        artistId: artistId,
        artistName: 'Ludmilla',
        fanDisplayName: 'Rafa Nogueira',
        fanHandle: 'rafanogueira',
        fanAvatarUri: _avatarRafa,
        votesCount: 4,
        sendsCount: 1,
        artistUpvoted: false,
        postedAt: 0,
        bodyText: 'SEMPRE AQUI',
        backgroundId: 'paper-cream',
      ),
      FanLetter(
        id: 'cf181-9',
        artistId: artistId,
        artistName: 'Ludmilla',
        fanDisplayName: 'Vic Melo',
        fanHandle: 'vicmelo',
        fanAvatarUri: _avatarVic,
        votesCount: 3,
        sendsCount: 1,
        artistUpvoted: false,
        postedAt: 0,
        bodyText: 'TE AMO LU',
        backgroundId: 'pattern-dots',
      ),
    ];
  }

  /// Stickers compactos da grade (print image4/image5).
  static List<FanLetterPlacedSticker> stickersFor(String letterId) {
    const coffee =
        'assets/Stickers/Capybara/CapybaraCharacterSticker_coffee.png';
    const cake = 'assets/Stickers/Birthday/Artboard 4@2x.png';
    const paw = 'assets/Stickers/kawaii stickers/paw.png';
    const peach = 'assets/Stickers/kawaii stickers/peach.png';
    const cactus = 'assets/Stickers/kawaii stickers/cactus.png';
    const heart = 'assets/Stickers/kawaii stickers/heart-smile.png';
    const gift = 'assets/Stickers/kawaii stickers/gift-box.png';
    const star = 'assets/Stickers/kawaii stickers/star-smile.png';
    const xoxo = 'assets/Stickers/kawaii stickers/xoxo.png';
    // Offsets relativos ao tile ~3:4 (preview compacto).
    return switch (letterId) {
      'cf181-1' => [
        const FanLetterPlacedSticker(
          id: 's1',
          asset: coffee,
          offset: Offset(28, 72),
        ),
      ],
      'cf181-2' => [
        const FanLetterPlacedSticker(
          id: 's2',
          asset: cake,
          offset: Offset(30, 70),
        ),
      ],
      'cf181-3' => [
        const FanLetterPlacedSticker(
          id: 's3',
          asset: paw,
          offset: Offset(32, 74),
        ),
      ],
      'cf181-4' => [
        const FanLetterPlacedSticker(
          id: 's4',
          asset: peach,
          offset: Offset(34, 72),
        ),
      ],
      'cf181-5' => [
        const FanLetterPlacedSticker(
          id: 's5',
          asset: cactus,
          offset: Offset(34, 70),
        ),
      ],
      'cf181-6' => [
        const FanLetterPlacedSticker(
          id: 's6',
          asset: heart,
          offset: Offset(32, 72),
        ),
      ],
      'cf181-7' => [
        const FanLetterPlacedSticker(
          id: 's7',
          asset: gift,
          offset: Offset(34, 72),
        ),
      ],
      'cf181-8' => [
        const FanLetterPlacedSticker(
          id: 's8',
          asset: star,
          offset: Offset(34, 70),
        ),
      ],
      'cf181-9' => [
        const FanLetterPlacedSticker(
          id: 's9',
          asset: xoxo,
          offset: Offset(32, 72),
        ),
      ],
      _ => const [],
    };
  }
}

/// CF-169/170 packs — fixture de print (só testes). Catálogo live = API (CF-270).
const bool kUseCf170WalletPackMocks = false;

/// CF-171 — checkout PIX pendente com código (print etapas 01/02/03).
/// **TEMP** até o gateway real emitir `pending` + `pixCopyPaste` (hoje o
/// sandbox costuma devolver `paid` e pular a tela de instruções).
const bool kUseCf171PixCheckoutMocks = true;

/// Recibo demo CF-171 (código PIX + status pending, sem mensagem técnica).
abstract final class Cf171PixCheckoutMock {
  static const pixCopyPaste =
      '00020126580014BR.GOV.BCB.PIX0136123e4567-e12b-12d1-a456-426614174000520400005303986540519.905802BR5925CrowdFans Pagamentos6009SAO PAULO62070503***6304ABCD';

  static WalletCheckoutResult pending({
    required String packId,
    int coins = 240,
  }) {
    return WalletCheckoutResult(
      checkoutId: 'cf171-pix-mock',
      packId: packId,
      coins: coins,
      status: 'pending',
      provider: 'pix',
      pixCopyPaste: pixCopyPaste,
    );
  }
}

/// Fixture print CF-169/170 (espelha `GET /api/v1/jam-coin-packs` pós CF-270).
abstract final class Cf170WalletPackMock {
  static List<JamCoinPack> packs() {
    return const [
      JamCoinPack(
        id: 'pack_120',
        productId: 'jam_120',
        coins: 120,
        priceCents: 990,
        label: '120 JC',
      ),
      JamCoinPack(
        id: 'pack_240',
        productId: 'jam_240',
        coins: 240,
        priceCents: 1990,
        label: '200 JC + 40 bônus',
      ),
      JamCoinPack(
        id: 'pack_600',
        productId: 'jam_600',
        coins: 600,
        priceCents: 4990,
        label: '500 JC + 100 bônus',
      ),
      JamCoinPack(
        id: 'pack_1300',
        productId: 'jam_1300',
        coins: 1300,
        priceCents: 9990,
        label: '1.000 JC + 300 bônus',
      ),
      JamCoinPack(
        id: 'pack_2100',
        productId: 'jam_2100',
        coins: 2100,
        priceCents: 14990,
        label: '1.600 JC + 500 bônus',
      ),
      JamCoinPack(
        id: 'pack_2800',
        productId: 'jam_2800',
        coins: 2800,
        priceCents: 19999,
        label: '2.000 JC + 800 bônus',
      ),
    ];
  }
}

/// Resolve catálogo da tela de recarga (CF-169/CF-270).
/// TEMP off: usa o que a API devolve. Não sobrescreve mais Starter/Plus/Pro.
List<JamCoinPack> resolveWalletRechargePacks(
  List<JamCoinPack> apiPacks, {
  bool? useTempMocks,
}) {
  final useMocks = useTempMocks ?? (kUseCfTempMocks && kUseCf170WalletPackMocks);
  if (useMocks) {
    return Cf170WalletPackMock.packs();
  }
  return apiPacks;
}

/// CF-182 — amostra do print Ludmilla (só testes de widget; app usa API CF-269).
abstract final class Cf182ArtistSobreMock {
  static const location = 'Rio de Janeiro, BR';
  static const trackTitle = 'Maldivas';
  static const playlistSubtitle = 'Playlist em destaque';
  static const monthlyListeners = '8,9 mi ouvintes';
  static const genre = 'Pop e R&B';
  static const openSpotifyAlbum = 'Numanice #3';
  static const instagramHandle = '@ludmilla';
  static const youtubeHandle = 'Ludmilla';
}

/// CF-198 — mock TEMP desligado. Conteúdo oficial: [HelpContent].
const bool kUseCf198HelpMocks = false;

/// CF-198 — legado empty flag (não usado pela tela após demock).
const bool kCf198MockEmpty = false;

/// True quando o mock TEMP da Central de ajuda (CF-198) está ativo.
/// Após demock: sempre false — a UI usa [HelpContent].
bool cf198HelpFixturesEnabled() =>
    kUseCfTempMocks &&
    CfTempMocks.useHelpFixtures &&
    kUseCf198HelpMocks &&
    !kCf198MockEmpty;

/// Item de acesso rápido da Ajuda (alias do print CF-198).
typedef Cf198QuickAccess = HelpQuickAccessItem;

/// Seção FAQ da Ajuda (alias do print CF-198).
typedef Cf198FaqSection = HelpFaqSectionData;

/// Sample do print CF-198 — delega a [HelpContent] (democked).
abstract final class Cf198HelpFixtures {
  static const headerTitle = HelpContent.headerTitle;
  static const heroTitle = HelpContent.heroTitle;
  static const intro = HelpContent.intro;
  static const quickAccessSectionTitle = HelpContent.quickAccessSectionTitle;
  static const supportLabel = HelpContent.supportLabel;
  static const supportSemantics = HelpContent.supportSemantics;
  static const supportEmail = HelpContent.supportEmail;

  static List<Cf198QuickAccess> quickAccess() => HelpContent.quickAccess();

  static List<Cf198FaqSection> faqSections() => HelpContent.faqSections();
}
