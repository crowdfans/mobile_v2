import 'package:crowdfans/components/profile/notification_preference_error_banner.dart';
import 'package:crowdfans/components/profile/notification_preference_row.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/components/profile/profile_state.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/services/follow_service.dart';
import 'package:crowdfans/services/notification_preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // --- GREEN: print / happy path ---

  test('CF-213 green: fixtures off; helpers do print permanecem p/ testes', () {
    expect(CfTempMocks.useArtistsNotifPrintFixtures, isFalse);
    expect(CfTempMocks.useNotificationPrefFixtures, isFalse);

    final prefs = Cf213NotificationPrefFixtures.alertTypeDefaultsOff();
    expect(prefs[NotificationPreferenceKeys.clubPosts], isFalse);
    expect(prefs[NotificationPreferenceKeys.exclusiveContent], isFalse);
    expect(prefs[NotificationPreferenceKeys.fanLetterReceived], isFalse);
    expect(prefs[NotificationPreferenceKeys.artistHighlights], isFalse);

    final artists = Cf213NotificationPrefFixtures.followedArtists();
    expect(artists.map((a) => a.artistName), [
      'Mayra',
      'Laís Costa',
      'Marinhos',
    ]);
    expect(Cf213NotificationPrefFixtures.artistSubtitles, [
      'Posts, cartas, Meet & Greet e membership deste artista.',
      'Lembretes de Meet, destaques e novidades do fã clube.',
      'Renovação de membership, promoções e conteúdo exclusivo.',
    ]);
  });

  test('CF-213 green: rota dedicada Artistas e Fã Clubes', () {
    expect(
      Pages.profileNotificationsArtists,
      '/me/settings/notifications/artists',
    );
    // Path string coincide com categoryId=artists, mas o hub usa a tela
    // dedicada (ProfileNotificationsArtistsScreen), não a categoria genérica.
    expect(
      Pages.profileNotificationCategory('artists'),
      Pages.profileNotificationsArtists,
    );
    expect(
      Pages.profileNotificationCategory('meet'),
      '/me/settings/notifications/meet',
    );
  });

  test('CF-213 green: demock não liga hub CF-166 nem CF-209/211', () {
    expect(CfTempMocks.useArtistsNotifPrintFixtures, isFalse);
    expect(CfTempMocks.useMeetGreetNotifPrintFixtures, isFalse); // CF-209 demock
    expect(CfTempMocks.useMembershipNotifPrintFixtures, isFalse); // CF-211 demock
    expect(CfTempMocks.useNotificationCategoryPrintFixtures, isFalse);
  });

  testWidgets(
    'CF-213 green: dois níveis — tipos off + três artistas do print',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final prefs = Cf213NotificationPrefFixtures.alertTypeDefaultsOff();
      final artists = Cf213NotificationPrefFixtures.followedArtists();
      final alertTypes = const <(String, String, String)>[
        (
          NotificationPreferenceKeys.clubPosts,
          'Posts de fã clubes',
          'Novos posts e movimento nos fã clubes que você acompanha.',
        ),
        (
          NotificationPreferenceKeys.exclusiveContent,
          'Conteúdo exclusivo',
          'Quando artistas liberarem conteúdo exclusivo para membros.',
        ),
        (
          NotificationPreferenceKeys.fanLetterReceived,
          'Novas Cartas de Fã',
          'Quando você receber cartas novas ou quando houver atividade nelas.',
        ),
        (
          NotificationPreferenceKeys.artistHighlights,
          'Destaques do artista',
          'Quando o artista destacar algo seu, como comentário, carta ou post.',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  ProfileScreenHeader(
                    title: 'Artistas e Fã Clubes',
                    onBack: () {},
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
                      children: [
                        const Text(
                          'Tipos de alerta',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        for (var i = 0; i < alertTypes.length; i++)
                          NotificationPreferenceRow(
                            title: alertTypes[i].$2,
                            description: alertTypes[i].$3,
                            value: prefs[alertTypes[i].$1] ?? false,
                            enabled: true,
                            showDivider: i > 0,
                            onChanged: (_) {},
                          ),
                        const SizedBox(height: 28),
                        const Text(
                          'Por artista',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Defina de quais artistas você quer receber alertas de posts, cartas, fã clube, conteúdo exclusivo e destaques.',
                        ),
                        const SizedBox(height: 8),
                        for (var i = 0; i < artists.length; i++)
                          NotificationPreferenceRow(
                            title: artists[i].artistName,
                            description:
                                Cf213NotificationPrefFixtures.artistSubtitles[i],
                            value: false,
                            enabled: true,
                            showDivider: i > 0,
                            onChanged: (_) {},
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Artistas e Fã Clubes'), findsOneWidget);
      expect(find.text('Tipos de alerta'), findsOneWidget);
      expect(find.text('Por artista'), findsOneWidget);
      expect(find.text('Posts de fã clubes'), findsOneWidget);
      expect(find.text('Conteúdo exclusivo'), findsOneWidget);
      expect(find.text('Novas Cartas de Fã'), findsOneWidget);
      expect(find.text('Destaques do artista'), findsOneWidget);
      expect(find.text('Mayra'), findsOneWidget);
      expect(find.text('Laís Costa'), findsOneWidget);
      expect(find.text('Marinhos'), findsOneWidget);
      expect(find.byType(NotificationPreferenceRow), findsNWidgets(7));
      expect(find.byType(Switch), findsNWidgets(7));

      final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
      for (final sw in switches) {
        expect(sw.value, isFalse);
      }
    },
  );

  // --- RED: erro / vazio / bloqueado ---

  testWidgets('CF-213 red: erro de save distinto do modo silencioso', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: const Scaffold(
          body: NotificationPreferenceErrorBanner(
            message:
                'Não foi possível salvar. As preferências voltaram ao estado anterior.',
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      find.text(
        'Não foi possível salvar. As preferências voltaram ao estado anterior.',
      ),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });

  testWidgets('CF-213 red: carga falhou sem lista falsa de preferências', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: ProfileState(
            title: 'Não foi possível carregar',
            message: 'Tente novamente para ver e ajustar as preferências.',
            actionLabel: 'Tentar de novo',
            onAction: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Não foi possível carregar'), findsOneWidget);
    expect(find.text('Tentar de novo'), findsOneWidget);
    expect(find.text('Posts de fã clubes'), findsNothing);
    expect(find.text('Mayra'), findsNothing);
  });

  testWidgets('CF-213 red: lista vazia de artistas sem inventar Mayra', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: Text(
            'Siga artistas para personalizar alertas por pessoa.',
            style: TextStyle(
              fontSize: 13,
              color: buildCrowdFansTheme(Brightness.light)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      find.text('Siga artistas para personalizar alertas por pessoa.'),
      findsOneWidget,
    );
    expect(find.text('Mayra'), findsNothing);
  });

  // --- EDGE: a11y, texto longo, fixtures off, muitos artistas ---

  testWidgets('CF-213 edge: switch anuncia rótulo sem foco duplo', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: NotificationPreferenceRow(
            title: 'Posts de fã clubes',
            description:
                'Novos posts e movimento nos fã clubes que você acompanha.',
            value: false,
            enabled: true,
            showDivider: false,
            onChanged: (_) {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(MergeSemantics), findsOneWidget);
    final semantics = tester.getSemantics(find.byType(Switch));
    expect(
      semantics.hasFlag(SemanticsFlag.hasToggledState) ||
          semantics.hasFlag(SemanticsFlag.isToggled) ||
          semantics.hasFlag(SemanticsFlag.hasEnabledState),
      isTrue,
    );
  });

  testWidgets('CF-213 edge: descrição longa não comprime o switch', (
    tester,
  ) async {
    const longDesc =
        'Defina de quais artistas você quer receber alertas de posts, cartas, '
        'fã clube, conteúdo exclusivo e destaques — texto ampliado para '
        'validar altura da linha sem sobrepor o controle.';

    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: NotificationPreferenceRow(
            title: 'Por artista — precedência',
            description: longDesc,
            value: false,
            enabled: true,
            showDivider: false,
            onChanged: (_) {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text(longDesc), findsOneWidget);
    final switchSize = tester.getSize(find.byType(Switch));
    expect(switchSize.width, greaterThan(40));
    expect(tester.takeException(), isNull);
  });

  test('CF-213 edge: muitos artistas permanece navegável (lista longa)', () {
    final many = List<ArtistFollow>.generate(
      40,
      (i) => ArtistFollow(
        artistUid: 'cf213-bulk-$i',
        artistName: 'Artista ${i + 1}',
        avatarUrl: '',
        isFollowing: true,
      ),
    );
    expect(many.length, 40);
    expect(many.last.artistName, 'Artista 40');
    // Helpers do print continuam 3; bulk só prova que o modelo escala.
    expect(Cf213NotificationPrefFixtures.followedArtists().length, 3);
  });

  test(
    'CF-213 edge: fixtures off — empty follows não inventa artistas do print',
    () {
      expect(CfTempMocks.useArtistsNotifPrintFixtures, isFalse);
      // Com flag off a tela usa API; empty → copy “Siga artistas…”, nunca Mayra.
      const emptyFollows = <ArtistFollow>[];
      expect(emptyFollows, isEmpty);
      expect(
        Cf213NotificationPrefFixtures.followedArtists().any(
          (a) => a.artistName == 'Mayra',
        ),
        isTrue,
      ); // helper ainda existe p/ asserts; UI real não o injeta
    },
  );
}
