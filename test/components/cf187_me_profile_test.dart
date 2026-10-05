import 'package:crowdfans/components/navigation/bottom_nav_profile_tab.dart';
import 'package:crowdfans/components/profile/me_fan_club_filter_field.dart';
import 'package:crowdfans/components/profile/me_posts_filter_chip.dart';
import 'package:crowdfans/components/profile/me_profile_actions_row.dart';
import 'package:crowdfans/components/profile/me_profile_toolbar.dart';
import 'package:crowdfans/components/profile/profile_identity_block.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/models/profile.dart';
import 'package:crowdfans/screens/main/me_screen.dart';
import 'package:crowdfans/state/auth_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeFanAuth extends AuthSessionNotifier {
  @override
  AuthSession build() {
    return const AuthSession(
      isLoading: false,
      isBackendValidated: true,
      profile: Profile(
        userUid: 'fan-empty',
        displayName: 'Vic Fan',
        name: 'Vic Fan',
        description: '',
        photoUrl: '',
        isArtist: false,
      ),
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

  test('CF-187 formatProfileCount pt-BR', () {
    expect(formatProfileCount(0), '0');
    expect(formatProfileCount(8), '8');
    expect(formatProfileCount(124), '124');
    expect(formatProfileCount(1180), '1.180');
    expect(formatProfileCount(12840), '12.840');
  });

  test('CF-187 fixtures batem o print preenchido', () {
    expect(kUseCf187MeProfileMocks, isTrue);
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

  testWidgets('CF-187 identidade: stats formatados + bio + avatar', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: ProfileIdentityBlock(
            profile: Cf187MeProfileFixtures.profile.copyWith(photoUrl: ''),
          ),
        ),
      ),
    );

    expect(find.text('Aline Duarte'), findsOneWidget);
    expect(find.text('fan/alineduarte'), findsOneWidget);
    expect(find.text('1.180'), findsOneWidget);
    expect(find.text('124'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('Posts'), findsOneWidget);
    expect(find.text('Cartas'), findsOneWidget);
    expect(find.text('Artistas'), findsOneWidget);
    expect(find.textContaining('rock e pop'), findsOneWidget);
  });

  testWidgets('CF-187 Editar Perfil com borda escura do print', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: MeProfileActionsRow(onEditProfile: () {}),
        ),
      ),
    );

    final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
    final side = button.style?.side?.resolve({});
    expect(side?.color, AppPalette.platinum800);
    expect(find.text('Editar Perfil'), findsOneWidget);
  });

  testWidgets('CF-187 toolbar + chips + seletor Fã Clube', (tester) async {
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

    expect(richTextContaining('Meu Perfil'), findsOneWidget);
    expect(richTextContaining('fan/alineduarte'), findsOneWidget);
    expect(find.text('Jams'), findsOneWidget);
    expect(find.text('Todos'), findsOneWidget);
    expect(find.text('Posts'), findsOneWidget);
    expect(find.text('Media'), findsOneWidget);
    expect(find.text('Filtrar por Fã Clube'), findsOneWidget);
    expect(find.byKey(const Key('me-fan-club-filter')), findsOneWidget);
  });

  testWidgets('CF-187 nav Meu Perfil anuncia selecionado', (tester) async {
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

  testWidgets('CF-187 MeScreen preenchido: seletor + posts + contagens', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(_FakeFanAuth.new),
        ],
        child: MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: const MeScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(richTextContaining('Meu Perfil'), findsOneWidget);
    expect(find.text('Aline Duarte'), findsAtLeastNWidgets(1));
    expect(find.text('1.180'), findsOneWidget);
    expect(find.text('Editar Perfil'), findsOneWidget);
    expect(find.text('Filtrar por Fã Clube'), findsOneWidget);
    expect(find.text('Todos'), findsOneWidget);
    expect(find.text('Nenhuma publicação'), findsNothing);
    expect(find.textContaining('mutirão'), findsOneWidget);
    expect(find.byKey(const Key('me-fan-club-filter')), findsOneWidget);
  });
}
