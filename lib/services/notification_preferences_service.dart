import 'package:crowdfans/api/api_urls.dart';
import 'package:crowdfans/services/http_service.dart';

/// Chaves de preferência de notificação suportadas pelo app.
abstract final class NotificationPreferenceKeys {
  static const pushEnabled = 'pushEnabled';
  static const emailEnabled = 'emailEnabled';
  static const quietModeEnabled = 'quietModeEnabled';
  static const artistLikeComment = 'artist-like-comment';
  static const artistLikeFanLetter = 'artist-like-fan-letter';
  static const commentReplies = 'comment-replies';
  static const mentions = 'mentions';
  static const newFollowers = 'new-followers';
  static const clubPosts = 'club-posts';
  static const exclusiveContent = 'exclusive-content';
  static const fanLetterReceived = 'fan-letter-received';
  static const artistHighlights = 'artist-highlights';
  static const meetInvites = 'meet-invites';
  static const meetReminders = 'meet-reminders';
  static const meetResults = 'meet-results';
  static const membershipRenewals = 'membership-renewals';
  static const jamCoinsPromos = 'jam-coins-promos';
  static const jamCoinsBalance = 'jam-coins-balance';

  static const all = <String>[
    pushEnabled,
    emailEnabled,
    quietModeEnabled,
    artistLikeComment,
    artistLikeFanLetter,
    commentReplies,
    mentions,
    newFollowers,
    clubPosts,
    exclusiveContent,
    fanLetterReceived,
    artistHighlights,
    meetInvites,
    meetReminders,
    meetResults,
    membershipRenewals,
    jamCoinsPromos,
    jamCoinsBalance,
  ];
}

/// Preferências de notificação usadas pelo aplicativo.
typedef NotificationPreferences = Map<String, bool>;

/// Valores iniciais usados até a resposta da API.
const notificationPreferenceDefaults = <String, bool>{
  NotificationPreferenceKeys.pushEnabled: true,
  NotificationPreferenceKeys.emailEnabled: false,
  NotificationPreferenceKeys.quietModeEnabled: false,
  NotificationPreferenceKeys.artistLikeComment: true,
  NotificationPreferenceKeys.artistLikeFanLetter: true,
  NotificationPreferenceKeys.commentReplies: true,
  NotificationPreferenceKeys.mentions: true,
  NotificationPreferenceKeys.newFollowers: true,
  NotificationPreferenceKeys.clubPosts: true,
  NotificationPreferenceKeys.exclusiveContent: true,
  NotificationPreferenceKeys.fanLetterReceived: true,
  NotificationPreferenceKeys.artistHighlights: true,
  NotificationPreferenceKeys.meetInvites: true,
  NotificationPreferenceKeys.meetReminders: true,
  NotificationPreferenceKeys.meetResults: true,
  NotificationPreferenceKeys.membershipRenewals: true,
  NotificationPreferenceKeys.jamCoinsPromos: true,
  NotificationPreferenceKeys.jamCoinsBalance: true,
};

/// Preferências de notificação (`GET/PUT /api/v1/notifications/preferences`).
abstract final class NotificationPreferencesService {
  /// Preenche chaves ausentes com o default do app.
  static NotificationPreferences normalize(Object? raw) {
    final map = (raw as Map?)?.cast<String, dynamic>() ?? {};
    return {
      for (final key in NotificationPreferenceKeys.all)
        key: map[key] is bool
            ? map[key] as bool
            : notificationPreferenceDefaults[key] ?? true,
    };
  }

  /// Busca as preferências do usuário autenticado.
  static Future<NotificationPreferences> getNotificationPreferences() {
    return HttpService.request(
      ApiUrls.notificationPreferences,
      timeout: const Duration(seconds: 10),
      parse: normalize,
    );
  }

  /// Persiste todas as preferências de notificação.
  static Future<NotificationPreferences> updateNotificationPreferences(
    NotificationPreferences preferences,
  ) {
    return HttpService.request(
      ApiUrls.notificationPreferences,
      method: Method.put,
      body: preferences,
      timeout: const Duration(seconds: 10),
      parse: normalize,
    );
  }
}
