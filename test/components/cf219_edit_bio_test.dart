import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/input/app_text_field.dart';
import 'package:crowdfans/components/profile/account_feedback_banner.dart';
import 'package:crowdfans/components/profile/profile_bio_field_meta.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/components/profile/profile_state.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/models/profile.dart';
import 'package:crowdfans/screens/profile/profile_account_screen.dart';
import 'package:crowdfans/screens/profile/profile_edit_bio_screen.dart';
import 'package:crowdfans/state/auth_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _FakeAuthSessionNotifier extends AuthSessionNotifier {
  _FakeAuthSessionNotifier(this._profile);

  final Profile? _profile;

  @override
  AuthSession build() {
    return AuthSession(
      isLoading: false,
      isBackendValidated: true,
      profile: _profile,
    );
  }
}

Profile _printProfile({String? description}) {
  return Profile(
    userUid: 'fan-1',
    displayName: 'fan/alineduarte',
    name: 'Aline Duarte',
    description: description ?? Cf219EditBioMock.bio,
    photoUrl: 'https://example.com/a.png',
    isArtist: false,
  );
}

Widget _wrapScreen({
  required Widget child,
  Profile? profile,
  bool allowNullProfile = false,
}) {
  return ProviderScope(
    overrides: [
      authSessionProvider.overrideWith(
        () => _FakeAuthSessionNotifier(
          allowNullProfile ? profile : (profile ?? _printProfile()),
        ),
      ),
    ],
    child: MaterialApp(
      theme: buildCrowdFansTheme(Brightness.light),
      home: child,
    ),
  );
}

/// CF-219 — Editar bio vs print + demock (description real; mock off).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CF-219 green', () {
    test('flag demock off; fixture print 56 chars', () {
      expect(kUseCf219EditBioMock, isFalse);
      expect(Cf219EditBioMock.bio.length, 56);
    });

    testWidgets('meta da bio: auxiliar + contador 56 do print', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: const Scaffold(
            body: ProfileBioFieldMeta(count: 56),
          ),
        ),
      );

      expect(find.text('Ela aparece no topo do seu perfil.'), findsOneWidget);
      expect(find.text('56'), findsOneWidget);
    });

    testWidgets('layout Editar bio vs print (description do profile)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrapScreen(child: const ProfileEditBioScreen()),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Editar bio'), findsOneWidget);
      expect(find.byType(ProfileScreenHeader), findsOneWidget);
      expect(find.text('Sua bio'), findsOneWidget);
      expect(find.text(Cf219EditBioMock.bio), findsOneWidget);
      expect(find.text('Ela aparece no topo do seu perfil.'), findsOneWidget);
      expect(find.text('56'), findsOneWidget);
      expect(find.text('Salvar bio'), findsOneWidget);

      // Sem formulário agregado (nome/username/foto misturados).
      expect(find.text('Editar perfil'), findsNothing);
      expect(find.text('Nome'), findsNothing);
      expect(find.text('Nome de usuário'), findsNothing);
      expect(find.text('Foto de perfil'), findsNothing);
      expect(find.text('Galeria'), findsNothing);
      expect(find.text('Câmera'), findsNothing);

      final field = tester.widget<AppTextField>(find.byType(AppTextField));
      expect(field.maxLines, 6);
      expect(field.maxLength, 180);
      expect(field.hint, 'Conte um pouco sobre você');

      final button = tester.widget<AppButton>(find.byType(AppButton));
      expect(button.disabled, isTrue);
      expect(button.label, 'Salvar bio');
    });

    testWidgets('digitar habilita Salvar; hub abre rota dedicada', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrapScreen(child: const ProfileEditBioScreen()),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(tester.widget<AppButton>(find.byType(AppButton)).disabled, isTrue);

      await tester.enterText(
        find.byType(TextFormField),
        '${Cf219EditBioMock.bio}!',
      );
      await tester.pump();

      expect(find.text('57'), findsOneWidget);
      expect(tester.widget<AppButton>(find.byType(AppButton)).disabled, isFalse);

      String? lastLocation;
      final router = GoRouter(
        initialLocation: Pages.profileAccount,
        routes: [
          GoRoute(
            path: Pages.profileAccount,
            builder: (context, state) => const ProfileAccountScreen(),
          ),
          GoRoute(
            path: Pages.profileEditBio,
            builder: (context, state) {
              lastLocation = state.uri.path;
              return const Scaffold(body: Center(child: Text('dest-bio')));
            },
          ),
          GoRoute(
            path: Pages.profilePhoto,
            builder: (context, state) => const SizedBox.shrink(),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authSessionProvider.overrideWith(
              () => _FakeAuthSessionNotifier(_printProfile()),
            ),
          ],
          child: MaterialApp.router(
            theme: buildCrowdFansTheme(Brightness.light),
            routerConfig: router,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      await tester.tap(find.text('Editar bio'));
      await tester.pumpAndSettle();

      expect(lastLocation, Pages.profileEditBio);
      expect(find.text('dest-bio'), findsOneWidget);
    });
  });

  group('CF-219 red', () {
    testWidgets('sem profile: estado indisponível (não injeta mock)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrapScreen(
          child: const ProfileEditBioScreen(),
          profile: null,
          allowNullProfile: true,
        ),
      );
      await tester.pump();
      // handleLoad falha sem HTTP → ProfileState de erro.
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text(Cf219EditBioMock.bio), findsNothing);
      expect(find.byType(ProfileState), findsOneWidget);
      expect(find.text('Perfil indisponível'), findsOneWidget);
      expect(find.text('Tentar novamente'), findsOneWidget);
      expect(find.text('Salvar bio'), findsNothing);
    });

    testWidgets('bio vazia: Salvar desabilitado; sem banner de sucesso', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrapScreen(
          child: const ProfileEditBioScreen(),
          profile: _printProfile(description: ''),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('0'), findsOneWidget);
      expect(tester.widget<AppButton>(find.byType(AppButton)).disabled, isTrue);
      expect(find.byType(AccountFeedbackBanner), findsNothing);
      expect(find.text(Cf219EditBioMock.bio), findsNothing);
    });
  });

  group('CF-219 edge', () {
    testWidgets('contagem por grapheme (emoji = 1)', (tester) async {
      await tester.pumpWidget(
        _wrapScreen(child: const ProfileEditBioScreen()),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      await tester.enterText(find.byType(TextFormField), 'oi👍');
      await tester.pump();
      expect(find.text('3'), findsOneWidget);
      expect(tester.widget<AppButton>(find.byType(AppButton)).disabled, isFalse);
    });

    testWidgets('texto longo: clamp 180 graphemes; Salvar habilitado', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrapScreen(
          child: const ProfileEditBioScreen(),
          profile: _printProfile(description: ''),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      final long = 'a' * 200;
      await tester.enterText(find.byType(TextFormField), long);
      await tester.pump();

      expect(find.text('180'), findsOneWidget);
      expect(tester.widget<AppButton>(find.byType(AppButton)).disabled, isFalse);
    });

    testWidgets('bio inalterada: Salvar permanece desabilitado', (tester) async {
      await tester.pumpWidget(
        _wrapScreen(child: const ProfileEditBioScreen()),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      await tester.enterText(
        find.byType(TextFormField),
        Cf219EditBioMock.bio,
      );
      await tester.pump();

      expect(find.text('56'), findsOneWidget);
      expect(tester.widget<AppButton>(find.byType(AppButton)).disabled, isTrue);
    });
  });
}
