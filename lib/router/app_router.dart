import 'dart:async';

import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/screens/artists/artist_profile_screen.dart';
import 'package:crowdfans/screens/comments/comments_screen.dart';
import 'package:crowdfans/screens/fan_clubs/fan_club_about_screen.dart';
import 'package:crowdfans/screens/fan_clubs/fan_club_community_screen.dart';
import 'package:crowdfans/screens/fan_clubs/fan_club_compose_screen.dart';
import 'package:crowdfans/screens/fan_clubs/fan_club_moderation_screen.dart';
import 'package:crowdfans/screens/fan_clubs/fan_club_moderators_screen.dart';
import 'package:crowdfans/screens/fan_clubs/fan_club_rules_screen.dart';
import 'package:crowdfans/screens/fan_clubs/fan_clubs_screen.dart';
import 'package:crowdfans/screens/fan_letter/fan_letter_compose_screen.dart';
import 'package:crowdfans/screens/fan_letter/fan_letter_gallery_screen.dart';
import 'package:crowdfans/screens/home/home_screen.dart';
import 'package:crowdfans/screens/login/artist_login_screen.dart';
import 'package:crowdfans/screens/login/fan_login_screen.dart';
import 'package:crowdfans/screens/main/main_shell.dart';
import 'package:crowdfans/screens/main/me_screen.dart';
import 'package:crowdfans/screens/notifications/notifications_screen.dart';
import 'package:crowdfans/screens/onboarding/presentation_screen.dart';
import 'package:crowdfans/screens/placeholder_screen.dart';
import 'package:crowdfans/screens/post/create_post_screen.dart';
import 'package:crowdfans/screens/post/my_posts_screen.dart';
import 'package:crowdfans/screens/profile/artist_audience_settings_screen.dart';
import 'package:crowdfans/screens/profile/artist_fan_club_settings_screen.dart';
import 'package:crowdfans/screens/profile/artist_insights_settings_screen.dart';
import 'package:crowdfans/screens/profile/blocked_users_settings_screen.dart';
import 'package:crowdfans/screens/profile/fan_club_contestation_list_screen.dart';
import 'package:crowdfans/screens/profile/fan_club_moderation_list_screen.dart';
import 'package:crowdfans/screens/profile/fan_profile_screen.dart';
import 'package:crowdfans/screens/profile/fan_score_screen.dart';
import 'package:crowdfans/screens/profile/hidden_posts_settings_screen.dart';
import 'package:crowdfans/screens/profile/moderation_settings_screen.dart';
import 'package:crowdfans/screens/profile/profile_account_screen.dart';
import 'package:crowdfans/screens/profile/profile_appearance_screen.dart';
import 'package:crowdfans/screens/profile/profile_artists_screen.dart';
import 'package:crowdfans/screens/profile/profile_earnings_screen.dart';
import 'package:crowdfans/screens/profile/profile_fan_score_screen.dart';
import 'package:crowdfans/screens/profile/profile_information_screen.dart';
import 'package:crowdfans/screens/profile/profile_memberships_screen.dart';
import 'package:crowdfans/screens/profile/profile_memories_screen.dart';
import 'package:crowdfans/screens/profile/profile_notifications_screen.dart';
import 'package:crowdfans/screens/profile/profile_pro_screen.dart';
import 'package:crowdfans/screens/profile/profile_referral_screen.dart';
import 'package:crowdfans/screens/profile/profile_security_screen.dart';
import 'package:crowdfans/screens/profile/profile_settings_screen.dart';
import 'package:crowdfans/screens/profile/profile_wallet_screen.dart';
import 'package:crowdfans/screens/register/fan/register_fan_birthdate_screen.dart';
import 'package:crowdfans/screens/register/fan/register_fan_email_screen.dart';
import 'package:crowdfans/screens/register/fan/register_fan_name_screen.dart';
import 'package:crowdfans/screens/register/fan/register_fan_otp_screen.dart';
import 'package:crowdfans/screens/register/fan/register_fan_password_screen.dart';
import 'package:crowdfans/screens/register/fan/register_fan_profile_screen.dart';
import 'package:crowdfans/screens/register/fan/register_fan_screen.dart';
import 'package:crowdfans/screens/register/fan/register_fan_success_screen.dart';
import 'package:crowdfans/screens/register/fan/register_fan_terms_screen.dart';
import 'package:crowdfans/screens/register/artist/register_artist_data_screen.dart';
import 'package:crowdfans/screens/register/artist/register_artist_email_screen.dart';
import 'package:crowdfans/screens/register/artist/register_artist_otp_screen.dart';
import 'package:crowdfans/screens/register/artist/register_artist_screen.dart';
import 'package:crowdfans/screens/register/fan/register_fan_username_screen.dart';
import 'package:crowdfans/screens/report/report_screen.dart';
import 'package:crowdfans/screens/search/search_ranking_screen.dart';
import 'package:crowdfans/screens/search/search_screen.dart';
import 'package:crowdfans/services/push_navigation_service.dart';
import 'package:crowdfans/services/report_service.dart';
import 'package:crowdfans/state/auth_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final _routerRefreshProvider = Provider<ValueNotifier<int>>((ref) {
  final notifier = ValueNotifier(0);
  ref.listen(authSessionProvider, (previous, next) {
    notifier.value++;
  });
  ref.onDispose(notifier.dispose);
  return notifier;
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ref.watch(_routerRefreshProvider);
  final router = GoRouter(
    initialLocation: Pages.presentation,
    refreshListenable: refresh,
    redirect: (context, state) {
      final rawPath =
          '${state.uri.path}${state.uri.hasQuery ? '?${state.uri.query}' : ''}';
      final incoming = Pages.fromIncomingLocation(
        state.uri.scheme == 'mobile' ? state.uri.toString() : rawPath,
      );
      if (incoming.split('?').first != state.matchedLocation &&
          incoming != rawPath) {
        return incoming;
      }
      final session = ref.read(authSessionProvider);
      if (session.isLoading) {
        return null;
      }
      final path = state.matchedLocation;
      final isPublic = Pages.publicPrefixes.any(path.startsWith);
      final isLoginFlow =
          path.startsWith('/login') || path.startsWith('/onboarding');
      final isRegister = path.startsWith('/register');

      if (!session.isAuthenticated && !isPublic) {
        return Pages.loginFan;
      }
      if (session.isAuthenticated && isLoginFlow && !isRegister) {
        return Pages.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: Pages.presentation,
        builder: (context, state) => const PresentationScreen(),
      ),
      GoRoute(
        path: Pages.loginFan,
        builder: (context, state) => const FanLoginScreen(),
      ),
      GoRoute(
        path: Pages.loginArtist,
        builder: (context, state) => const ArtistLoginScreen(),
      ),
      GoRoute(
        path: Pages.registerFan,
        builder: (context, state) => const RegisterFanScreen(),
      ),
      GoRoute(
        path: Pages.registerFanOtp,
        builder: (context, state) => const RegisterFanOtpScreen(),
      ),
      GoRoute(
        path: Pages.registerFanEmail,
        builder: (context, state) => const RegisterFanEmailScreen(),
      ),
      GoRoute(
        path: Pages.registerFanPassword,
        builder: (context, state) => const RegisterFanPasswordScreen(),
      ),
      GoRoute(
        path: Pages.registerFanName,
        builder: (context, state) => const RegisterFanNameScreen(),
      ),
      GoRoute(
        path: Pages.registerFanBirthdate,
        builder: (context, state) => const RegisterFanBirthdateScreen(),
      ),
      GoRoute(
        path: Pages.registerFanUsername,
        builder: (context, state) => const RegisterFanUsernameScreen(),
      ),
      GoRoute(
        path: Pages.registerFanProfile,
        builder: (context, state) => const RegisterFanProfileScreen(),
      ),
      GoRoute(
        path: Pages.registerFanTerms,
        builder: (context, state) => const RegisterFanTermsScreen(),
      ),
      GoRoute(
        path: Pages.registerFanSuccess,
        builder: (context, state) => const RegisterFanSuccessScreen(),
      ),
      GoRoute(
        path: Pages.registerArtist,
        builder: (context, state) => const RegisterArtistScreen(),
      ),
      GoRoute(
        path: Pages.registerArtistOtp,
        builder: (context, state) => const RegisterArtistOtpScreen(),
      ),
      GoRoute(
        path: Pages.registerArtistEmail,
        builder: (context, state) => const RegisterArtistEmailScreen(),
      ),
      GoRoute(
        path: Pages.registerArtistData,
        builder: (context, state) => const RegisterArtistDataScreen(),
      ),
      GoRoute(
        path: Pages.artistProfile,
        builder: (context, state) => ArtistProfileScreen(
          artistId: state.pathParameters['artistId'] ?? '',
        ),
      ),
      GoRoute(
        path: Pages.fanClubCommunity,
        builder: (context, state) => FanClubCommunityScreen(
          artistId: state.pathParameters['artistId'] ?? '',
          seedName: state.uri.queryParameters['name'],
          seedAvatarUrl: state.uri.queryParameters['avatarUrl'],
        ),
      ),
      GoRoute(
        path: Pages.fanClubAbout,
        builder: (context, state) => FanClubAboutScreen(
          artistId: state.uri.queryParameters['artistId'] ?? '',
          artistName: state.uri.queryParameters['name'],
        ),
      ),
      GoRoute(
        path: Pages.fanClubRules,
        builder: (context, state) => const FanClubRulesScreen(),
      ),
      GoRoute(
        path: Pages.fanClubModerators,
        builder: (context, state) => FanClubModeratorsScreen(
          artistId: state.uri.queryParameters['artistId'] ?? '',
        ),
      ),
      GoRoute(
        path: Pages.fanClubModeration,
        builder: (context, state) => FanClubModerationScreen(
          artistId: state.uri.queryParameters['artistId'] ?? '',
        ),
      ),
      GoRoute(
        path: Pages.fanScorePublic,
        builder: (context, state) =>
            FanScoreScreen(fanHandle: state.pathParameters['fanHandle'] ?? ''),
      ),
      GoRoute(
        path: Pages.fanProfile,
        builder: (context, state) => FanProfileScreen(
          fanHandle: state.pathParameters['fanHandle'] ?? '',
        ),
      ),
      GoRoute(
        path: Pages.profileArtists,
        builder: (context, state) =>
            ProfileArtistsScreen(handle: state.uri.queryParameters['handle']),
      ),
      GoRoute(
        path: Pages.profileSettings,
        builder: (context, state) => const ProfileSettingsScreen(),
      ),
      GoRoute(
        path: Pages.profileAccount,
        builder: (context, state) => const ProfileAccountScreen(),
      ),
      GoRoute(
        path: Pages.profileSecurity,
        builder: (context, state) => const ProfileSecurityScreen(),
      ),
      GoRoute(
        path: Pages.profileAppearance,
        builder: (context, state) => const ProfileAppearanceScreen(),
      ),
      GoRoute(
        path: Pages.profileInformation,
        builder: (context, state) => const ProfileInformationScreen(),
      ),
      GoRoute(
        path: Pages.profileHiddenPosts,
        builder: (context, state) => const HiddenPostsSettingsScreen(),
      ),
      GoRoute(
        path: Pages.profileMemories,
        builder: (context, state) => const ProfileMemoriesScreen(),
      ),
      GoRoute(
        path: Pages.profileBlockedUsers,
        builder: (context, state) => const BlockedUsersSettingsScreen(),
      ),
      GoRoute(
        path: Pages.profileNotifications,
        builder: (context, state) => const ProfileNotificationsScreen(),
      ),
      GoRoute(
        path: Pages.profileWallet,
        builder: (context, state) => const ProfileWalletScreen(),
      ),
      GoRoute(
        path: Pages.profilePro,
        builder: (context, state) => const ProfileProScreen(),
      ),
      GoRoute(
        path: Pages.profileMemberships,
        builder: (context, state) => const ProfileMembershipsScreen(),
      ),
      GoRoute(
        path: Pages.profileReferral,
        builder: (context, state) => const ProfileReferralScreen(),
      ),
      GoRoute(
        path: Pages.profileEarnings,
        builder: (context, state) => const ProfileEarningsScreen(),
      ),
      GoRoute(
        path: Pages.profileFanScore,
        builder: (context, state) => const ProfileFanScoreScreen(),
      ),
      GoRoute(
        path: Pages.profileArtistInsights,
        builder: (context, state) => const ArtistInsightsSettingsScreen(),
      ),
      GoRoute(
        path: Pages.profileArtistAudience,
        builder: (context, state) => const ArtistAudienceSettingsScreen(),
      ),
      GoRoute(
        path: Pages.profileArtistFanClub,
        builder: (context, state) => const ArtistFanClubSettingsScreen(),
      ),
      GoRoute(
        path: Pages.profileModeration,
        builder: (context, state) => const ModerationSettingsScreen(),
      ),
      GoRoute(
        path: Pages.profileModerationList,
        builder: (context, state) => const FanClubModerationListScreen(),
      ),
      GoRoute(
        path: Pages.profileContestations,
        builder: (context, state) => const FanClubContestationListScreen(),
      ),
      GoRoute(
        path: Pages.createPost,
        builder: (context, state) => CreatePostScreen(
          postId: state.uri.queryParameters['postId'],
          targetArtistId: state.uri.queryParameters['targetArtistId'],
        ),
      ),
      GoRoute(
        path: Pages.myPosts,
        builder: (context, state) => const MyPostsScreen(),
      ),
      GoRoute(
        path: Pages.fanClubCompose,
        builder: (context, state) => FanClubComposeScreen(
          artistId: state.uri.queryParameters['artistId'],
          artistName: state.uri.queryParameters['name'],
          avatarUrl: state.uri.queryParameters['avatarUrl'],
        ),
      ),
      GoRoute(
        path: Pages.fanLetterGallery,
        builder: (context, state) => const FanLetterGalleryScreen(),
      ),
      GoRoute(
        path: Pages.fanLetterCompose,
        builder: (context, state) => FanLetterComposeScreen(
          artistId: state.uri.queryParameters['artistId'],
          artistName: state.uri.queryParameters['name'],
          avatarUrl: state.uri.queryParameters['avatarUrl'],
        ),
      ),
      GoRoute(
        path: Pages.comments,
        builder: (context, state) =>
            CommentsScreen(postId: state.pathParameters['postId'] ?? ''),
      ),
      GoRoute(
        path: Pages.searchRanking,
        builder: (context, state) => SearchRankingScreen(
          kind: state.uri.queryParameters['kind'] ?? 'fan-clubs',
        ),
      ),
      GoRoute(
        path: Pages.report,
        builder: (context, state) => ReportScreen(
          contextKind: ReportService.parseContext(
            state.uri.queryParameters['context'],
          ),
          targetId: state.uri.queryParameters['targetId'],
          displayName: state.uri.queryParameters['displayName'],
        ),
      ),
      GoRoute(
        path: Pages.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: Pages.demo,
        builder: (context, state) => const PlaceholderScreen(
          title: 'Demo',
          message: 'Só existe se o Expo ainda usar esta rota.',
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Pages.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Pages.clubs,
                builder: (context, state) => const FanClubsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Pages.explore,
                builder: (context, state) => const SearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Pages.me,
                builder: (context, state) => const MeScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(PushNavigationService.detach);
  unawaited(PushNavigationService.attach(router));
  return router;
});
