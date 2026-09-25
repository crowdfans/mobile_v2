// TEMP MOCK — delete this file when API is ready
//
// CF-190: dados fictícios da central de notificações (print image.png).
// Para desligar: `kUseCf190Mocks = false`. Para forçar vazio: `kCf190MockEmpty = true`.
// Depois apague este arquivo e o import em `notifications_service.dart`.

import 'package:crowdfans/services/notifications_service.dart';

/// Liga a inbox à lista mock (QA / demo). Desligue antes de produção real.
const bool kUseCf190Mocks = true;

/// Quando `true` (e mocks ligados), a lista vem vazia — valida o empty state.
const bool kCf190MockEmpty = false;

/// Avatares / thumbs de exemplo (Unsplash). Rock-hand local para membership.
abstract final class Cf190NotificationsMock {
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

  /// Seções Agora / Hoje espelhando o print de referência CF-190.
  static List<NotificationSection> sections() {
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
