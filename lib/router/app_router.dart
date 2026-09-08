import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/screens/login/artist_login_screen.dart';
import 'package:crowdfans/screens/login/fan_login_screen.dart';
import 'package:crowdfans/screens/main/main_shell.dart';
import 'package:crowdfans/screens/main/me_screen.dart';
import 'package:crowdfans/screens/onboarding/presentation_screen.dart';
import 'package:crowdfans/screens/placeholder_screen.dart';
import 'package:crowdfans/screens/register/fan/register_fan_birthdate_screen.dart';
import 'package:crowdfans/screens/register/fan/register_fan_email_screen.dart';
import 'package:crowdfans/screens/register/fan/register_fan_name_screen.dart';
import 'package:crowdfans/screens/register/fan/register_fan_otp_screen.dart';
import 'package:crowdfans/screens/register/fan/register_fan_password_screen.dart';
import 'package:crowdfans/screens/register/fan/register_fan_profile_screen.dart';
import 'package:crowdfans/screens/register/fan/register_fan_screen.dart';
import 'package:crowdfans/screens/register/fan/register_fan_success_screen.dart';
import 'package:crowdfans/screens/register/fan/register_fan_terms_screen.dart';
import 'package:crowdfans/screens/register/fan/register_fan_username_screen.dart';
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
  return GoRouter(
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
        builder: (context, state) => const PlaceholderScreen(
          title: 'Cadastro Artista',
          message: 'Próximo na migração Expo → Flutter.',
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
                builder: (context, state) => const PlaceholderScreen(
                  title: 'Feed',
                  message:
                      'Home do Expo (`Pages.HOME`). Próximo: posts + stories.',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Pages.clubs,
                builder: (context, state) => const PlaceholderScreen(
                  title: 'Clubes',
                  message: 'Fan clubs (`Pages.FAN_CLUBS`).',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Pages.explore,
                builder: (context, state) => const PlaceholderScreen(
                  title: 'Explorar',
                  message: 'Busca de artistas (`Pages.SEARCH`).',
                ),
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
});
