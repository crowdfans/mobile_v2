import 'package:crowdfans/components/profile/notification_preference_error_banner.dart';
import 'package:crowdfans/components/profile/notification_preference_row.dart';
import 'package:crowdfans/components/profile/notification_preference_section.dart';
import 'package:crowdfans/components/profile/notification_quiet_mode_note.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/services/notification_preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // --- green ---
  test(
    'CF-208 catálogo Interações: intro + 5 rótulos/descrições do print',
    () {
      final group = notificationGroupById('interactions')!;
      expect(group.title, 'Interações com você'); // hub CF-166
      expect(group.headerTitle, 'Interações com Você'); // subpágina print
      expect(
        group.pageIntro,
        'Escolha quais interações pessoais merecem um alerta imediato, principalmente quando vierem do próprio artista.',
      );
      expect(group.navSubtitle, contains('menções ao seu fan/'));
      expect(group.items.map((item) => item.title).toList(), [
        'Artista curtiu seu comentário',
        'Artista curtiu sua carta',
        'Respostas aos seus comentários',
        'Menções ao seu fan/',
        'Novos seguidores',
      ]);
      expect(group.items.map((item) => item.description).toList(), [
        'Quando o próprio artista curtir especificamente um comentário seu.',
        'Quando o artista der upvote ou destaque na sua Carta de Fã.',
        'Quando responderem um comentário seu em posts e fã clubes.',
        'Quando alguém mencionar o seu fan/ em comentários, posts ou cartas.',
        'Quando novos fãs começarem a seguir você.',
      ]);
      expect(group.items.every((item) => item.critical == false), isTrue);
    },
  );

  test('CF-208 fixtures: 5 switches off (print); flag API real off', () {
    expect(CfTempMocks.useInteractionsNotifPrintFixtures, isFalse);
    expect(CfTempMocks.useNotificationCategoryPrintFixtures, isFalse);
    final prefs = Cf208209211NotificationPrintFixtures.preferences();
    expect(prefs[NotificationPreferenceKeys.artistLikeComment], isFalse);
    expect(prefs[NotificationPreferenceKeys.artistLikeFanLetter], isFalse);
    expect(prefs[NotificationPreferenceKeys.commentReplies], isFalse);
    expect(prefs[NotificationPreferenceKeys.mentions], isFalse);
    expect(prefs[NotificationPreferenceKeys.newFollowers], isFalse);
  });

  test('CF-208 rota da subpágina Interações', () {
    expect(
      Pages.profileNotificationCategory('interactions'),
      '/me/settings/notifications/interactions',
    );
  });

  testWidgets(
    'CF-208 tela Interações: header print, intro e 5 switches off',
    (tester) async {
      final group = notificationGroupById('interactions')!;
      final prefs = Cf208209211NotificationPrintFixtures.preferences();

      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  ProfileScreenHeader(
                    title: group.headerTitle,
                    onBack: () {},
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
                      children: [
                        Text(
                          group.pageIntro!,
                          style: const TextStyle(fontSize: 14, height: 1.4),
                        ),
                        const SizedBox(height: 20),
                        NotificationPreferenceSection(
                          group: group,
                          preferences: prefs,
                          saving: false,
                          onChanged: (_, __) {},
                          showTitle: false,
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
      await tester.pump();

      expect(find.text('Interações com Você'), findsOneWidget);
      expect(find.text('Interações com você'), findsNothing);
      expect(
        find.text(
          'Escolha quais interações pessoais merecem um alerta imediato, principalmente quando vierem do próprio artista.',
        ),
        findsOneWidget,
      );
      expect(find.text('Artista curtiu seu comentário'), findsOneWidget);
      expect(find.text('Artista curtiu sua carta'), findsOneWidget);
      expect(find.text('Respostas aos seus comentários'), findsOneWidget);
      expect(find.text('Menções ao seu fan/'), findsOneWidget);
      expect(find.text('Novos seguidores'), findsOneWidget);
      expect(find.byType(NotificationPreferenceRow), findsNWidgets(5));
      expect(find.byType(Switch), findsNWidgets(5));

      final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
      expect(switches.every((s) => s.value == false), isTrue);
      expect(switches.first.activeTrackColor, isNotNull);
    },
  );

  // --- red ---
  test('CF-208 flag não liga hub CF-166 nem CF-209/211/213', () {
    expect(CfTempMocks.useNotificationCategoryPrintFixtures, isFalse);
    expect(CfTempMocks.useInteractionsNotifPrintFixtures, isFalse);
    expect(CfTempMocks.useMeetGreetNotifPrintFixtures, isFalse);
    expect(CfTempMocks.useMembershipNotifPrintFixtures, isTrue);
    expect(CfTempMocks.useArtistsNotifPrintFixtures, isFalse); // CF-213 demock
    expect(CfTempMocks.useNotificationPrefFixtures, isFalse);
  });

  test('CF-208 categoria inválida não resolve grupo', () {
    expect(notificationGroupById('interactions-typo'), isNull);
    expect(notificationGroupById(''), isNull);
  });

  testWidgets(
    'CF-208 erro de save é visualmente distinto do modo silencioso',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: const Scaffold(
            body: Column(
              children: [
                NotificationPreferenceErrorBanner(
                  message:
                      'Não foi possível salvar. As preferências voltaram ao estado anterior.',
                ),
                NotificationQuietModeNote(),
              ],
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
      expect(find.byType(NotificationQuietModeNote), findsOneWidget);
      expect(find.byType(NotificationPreferenceErrorBanner), findsOneWidget);
    },
  );

  // --- edge ---
  testWidgets('CF-208 switch anuncia rótulo sem foco duplo (A11Y-01)', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: NotificationPreferenceRow(
            title: 'Menções ao seu fan/',
            description:
                'Quando alguém mencionar o seu fan/ em comentários, posts ou cartas.',
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

  testWidgets(
    'CF-208 quiet mode desabilita linhas não-críticas sem esconder rótulos',
    (tester) async {
      final group = notificationGroupById('interactions')!;
      final prefs = {
        ...Cf208209211NotificationPrintFixtures.preferences(),
        NotificationPreferenceKeys.quietModeEnabled: true,
      };

      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: NotificationPreferenceSection(
              group: group,
              preferences: prefs,
              saving: false,
              onChanged: (_, __) {},
              showTitle: false,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Artista curtiu seu comentário'), findsOneWidget);
      expect(find.text('Novos seguidores'), findsOneWidget);
      final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
      expect(switches.length, 5);
      expect(switches.every((s) => s.onChanged == null), isTrue);
    },
  );

  testWidgets('CF-208 descrição longa não comprime o switch', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: NotificationPreferenceRow(
            title: 'Artista curtiu seu comentário',
            description:
                'Quando o próprio artista curtir especificamente um comentário seu. '
                'Texto ampliado para validar que a linha cresce em altura e o switch '
                'permanece alinhado à direita sem sobrepor a explicação.',
            value: false,
            enabled: true,
            showDivider: true,
            onChanged: (_) {},
          ),
        ),
      ),
    );
    await tester.pump();

    final switchBox = tester.getRect(find.byType(Switch));
    final titleBox = tester.getRect(find.text('Artista curtiu seu comentário'));
    expect(switchBox.left, greaterThan(titleBox.right));
    expect(find.byType(Switch), findsOneWidget);
  });
}
