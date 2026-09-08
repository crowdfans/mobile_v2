import 'dart:async';

import 'package:crowdfans/models/profile.dart';
import 'package:crowdfans/services/auth_service.dart';
import 'package:crowdfans/services/firebase_service.dart';
import 'package:crowdfans/services/profile_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sessão Firebase + validação no backend CrowdFans.
class AuthSession {
  const AuthSession({
    this.user,
    this.profile,
    this.isLoading = true,
    this.isBackendValidated = false,
  });

  final User? user;
  final Profile? profile;
  final bool isLoading;
  final bool isBackendValidated;

  bool get isAuthenticated => user != null && isBackendValidated;

  AuthSession copyWith({
    User? user,
    Profile? profile,
    bool? isLoading,
    bool? isBackendValidated,
    bool clearUser = false,
    bool clearProfile = false,
  }) {
    return AuthSession(
      user: clearUser ? null : (user ?? this.user),
      profile: clearProfile ? null : (profile ?? this.profile),
      isLoading: isLoading ?? this.isLoading,
      isBackendValidated: isBackendValidated ?? this.isBackendValidated,
    );
  }
}

class AuthSessionNotifier extends Notifier<AuthSession> {
  StreamSubscription<User?>? _sub;

  @override
  AuthSession build() {
    ref.onDispose(() => _sub?.cancel());
    _sub = FirebaseService.auth.authStateChanges().listen(_onAuth);
    return const AuthSession();
  }

  Future<void> _onAuth(User? user) async {
    if (user == null) {
      state = const AuthSession(isLoading: false);
      return;
    }
    state = state.copyWith(user: user, isLoading: true);
    await _validate(user, forceRefresh: false);
  }

  Future<bool> refreshSession() async {
    final user = FirebaseService.auth.currentUser;
    if (user == null) {
      state = const AuthSession(isLoading: false);
      return false;
    }
    return _validate(user, forceRefresh: true);
  }

  Future<bool> _validate(User user, {required bool forceRefresh}) async {
    try {
      final token = await user.getIdToken(forceRefresh);
      if (token == null) {
        throw StateError('token vazio');
      }
      await AuthService.verifyBackendFirebaseToken(token);
      final profile = await ProfileService.getMyProfile();
      state = AuthSession(
        user: user,
        profile: profile,
        isLoading: false,
        isBackendValidated: true,
      );
      return true;
    } catch (_) {
      state = AuthSession(
        user: user,
        isLoading: false,
        isBackendValidated: false,
      );
      return false;
    }
  }

  Future<void> logout() async {
    await FirebaseService.auth.signOut();
    state = const AuthSession(isLoading: false);
  }
}

final authSessionProvider =
    NotifierProvider<AuthSessionNotifier, AuthSession>(AuthSessionNotifier.new);
