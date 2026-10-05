import 'package:crowdfans/components/navigation/bottom_nav_profile_tab.dart';
import 'package:crowdfans/components/profile/me_fan_club_filter_field.dart';
import 'package:crowdfans/components/profile/me_posts_filter_chip.dart';
import 'package:crowdfans/components/profile/me_profile_actions_row.dart';
import 'package:crowdfans/components/profile/me_profile_toolbar.dart';
import 'package:crowdfans/components/profile/profile_identity_block.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/models/fan_profile.dart';
import 'package:crowdfans/models/profile.dart';
import 'package:crowdfans/screens/main/me_screen.dart';
import 'package:crowdfans/state/auth_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeFanAuth extends AuthSessionNotifier {
  _FakeFanAuth(this.profile);

  final Profile? profile;

  @override
  AuthSession build() {
    return AuthSession(
      isLoading: false,
      isBackendValidated: true,
      profile: profile,
    );
  }
}

Finder richTextContaining(String needle) {
  return find.byWidgetPredicate(
    (widget) =>
        widget is RichText && widget.text.toPlainText().contains(needle),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // --- Green ---
  test('CF-187 green: formatProfileCount pt-BR + fixtures print', () {
    expect(formatProfileCount(0), '0');
    expect(formatProfileCount(8), '8');
    expect(formatProfileCount(124), '124');
    expect(formatProfileCount(1180), '1.180');
    expect(formatProfileCount(12840), '12.840');

    expect(kUseCf187MeProfileMocks, isFalse); // demock
    final profile = Cf187MeProfileFixtures.profile;
    expect(profile.displayName, 'Aline Duarte');
    expect(profile.name, 'alineduarte');
    expect(profile.stats.postsCount, 1180);
    expect(profile.stats.cartasCount, 124);
    expect(profile.stats.artistasCount, 8);
    expect(profile.description, contains('rock e pop'));
    expect(profile.photoUrl, isNotEmpty);
    expect(Cf187MeProfileFixtures.followedArtists(), isNotEmpty);
    expect(Cf187MeProfileFixtures.posts(), isNotEmpty);
    expect(Cf187MeProfileFixtures.posts().first.isSecret, isTrue);
    expect(
      Cf187MeProfileFixtures.posts().first.membershipBadges.first.label,
      '3',
    );
  });

  testWidgets('CF-187 green: identidade stats + bio + Editar + seletor', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                MeProfileToolbar(
                  handle: 'alineduarte',
                  onJams: () {},
                  onSettings: () {},
                ),
                ProfileIdentityBlock(
                  profile: Cf187MeProfileFixtures.profile.copyWith(
                    photoUrl: '',
                  ),
                ),
                MeProfileActionsRow(onEditProfile: () {}),
                Row(
                  children: [
                    MePostsFilterChip(
                      label: 'Todos',
                      selected: true,
                      onPressed: () {},
                    ),
                    MePostsFilterChip(
                      label: 'Posts',
                      selected: false,
                      onPressed: () {},
                    ),
                    MePostsFilterChip(
                      label: 'Media',
                      selected: false,
                      onPressed: () {},
                    ),
                  ],
                ),
                MeFanClubFilterField(
                  selected: null,
                  expanded: false,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Aline Duarte'), findsOneWidget);
    expect(find.text('fan/alineduarte'), findsWidgets);
    expect(find.text('1.180'), findsOneWidget);
    expect(find.text('124'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.textContaining('rock e pop'), findsOneWidget);
    expect(find.text('Editar Perfil'), findsOneWidget);
    expect(find.text('Filtrar por Fã Clube'), findsOneWidget);
    expect(find.byKey(const Key('me-fan-club-filter')), findsOneWidget);

    final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
    final side = button.style?.side?.resolve({});
    expect(side?.color, AppPalette.platinum800);
  });

  testWidgets('CF-187 green: nav Meu Perfil anuncia selecionado', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: Row(
            children: [
              BottomNavProfileTab(
                selected: true,
                photoUrl: '',
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );

    expect(
      find.bySemanticsLabel('Meu Perfil, selecionado'),
      findsOneWidget,
    );
  });

  // --- Red ---
  testWidgets('CF-187 red: MeScreen sem mock + perfil vazio → empty state', (
    tester,
  ) async {
    expect(kUseCf187MeProfileMocks, isFalse);

    await tester.binding.setSurfaceSize(const Size(390, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(
            () => _FakeFanAuth(
              const Profile(
                userUid: '',
                displayName: '',
                name: '',
                description: '',
                photoUrl: '',
                isArtist: false,
              ),
            ),
          ),
        ],
        child: MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: const MeScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Sem fixtures TEMP: não inventa Aline / posts do print.
    expect(find.text('Aline Duarte'), findsNothing);
    expect(find.textContaining('mutirão'), findsNothing);
    expect(find.text('Nenhuma publicação'), findsOneWidget);
    // Estrutura da tela permanece (seletor + Editar com perfil de sessão vazio).
    expect(find.text('Filtrar por Fã Clube'), findsOneWidget);
    expect(find.text('Editar Perfil'), findsOneWidget);
  });

  // --- Edge ---
  test('CF-187 edge: mergeMeFollowedArtists dedupe + overview-only', () async {
    final overview = [
      const FollowedArtist(
        id: 'a1',
        label: 'Mayra',
        memberCount: '10',
        avatarUri: '',
      ),
      const FollowedArtist(
        id: 'a1',
        label: 'Mayra dup',
        memberCount: '10',
        avatarUri: '',
      ),
    ];
    // Sem HTTP: merge só preserva overview (catch interno se FollowService falhar).
    final merged = await mergeMeFollowedArtists(overview);
    expect(merged, isNotEmpty);
    expect(merged.first.id, 'a1');
    expect(merged.first.label, 'Mayra');
  });

  test('CF-187 edge: contagem zero e bio longa nas fixtures', () {
    expect(formatProfileCount(0), '0');
    final long = Cf187MeProfileFixtures.profile.description;
    expect(long.length, greaterThan(40));
    expect(kUseCf187MeProfileMocks, isFalse);
  });
}
