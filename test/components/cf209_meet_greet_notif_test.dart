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
    'CF-209 catálogo Meet & Greet: intro + ordem convites → lembretes → resultado',
    () {
      final group = notificationGroupById('meet')!;
      expect(group.title, 'Meet & Greet');
      expect(
        group.pageIntro,
        'Controle desde convites e lembretes de fila até os avisos de encerramento das chamadas.',
      );
      expect(group.navSubtitle, contains('Convites'));
      expect(group.items.map((item) => item.title).toList(), [
        'Convites para Meet & Greet',
        'Lembretes de Meet & Greet',
        'Resultado e encerramento',
      ]);
      expect(group.items.map((item) => item.description).toList(), [
        'Quando você for selecionado ou convocado para uma chamada.',
        'Avisos antes da chamada, entrada na fila e início da sua vez.',
        'Quando o Meet terminar ou quando a janela de acesso mudar.',
      ]);
      expect(group.items[0].critical, isTrue);
      expect(group.items[1].critical, isTrue);
      expect(group.items[2].critical, isFalse);
    },
  );

  test(
    'CF-209 defaults + fixtures: convites/lembretes on, resultado off (print); flag API',
    () {
      expect(CfTempMocks.useMeetGreetNotifPrintFixtures, isFalse);
      expect(CfTempMocks.useNotificationCategoryPrintFixtures, isFalse);

      expect(
        notificationPreferenceDefaults[NotificationPreferenceKeys.meetInvites],
        isTrue,
      );
      expect(
        notificationPreferenceDefaults[NotificationPreferenceKeys.meetReminders],
        isTrue,
      );
      expect(
        notificationPreferenceDefaults[NotificationPreferenceKeys.meetResults],
        isFalse,
      );

      final prefs = Cf208209211NotificationPrintFixtures.preferences();
      expect(prefs[NotificationPreferenceKeys.meetInvites], isTrue);
      expect(prefs[NotificationPreferenceKeys.meetReminders], isTrue);
      expect(prefs[NotificationPreferenceKeys.meetResults], isFalse);
    },
  );

  test('CF-209 rota da subpágina Meet & Greet', () {
    expect(
      Pages.profileNotificationCategory('meet'),
      '/me/settings/notifications/meet',
    );
  });

  testWidgets(
    'CF-209 tela Meet & Greet: header, intro e switches do print',
    (tester) async {
      final group = notificationGroupById('meet')!;
      final prefs = Cf208209211NotificationPrintFixtures.preferences();

      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  ProfileScreenHeader(
                    title: group.title,
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

      expect(find.text('Meet & Greet'), findsOneWidget);
      expect(
        find.text(
          'Controle desde convites e lembretes de fila até os avisos de encerramento das chamadas.',
        ),
        findsOneWidget,
      );
      expect(find.text('Convites para Meet & Greet'), findsOneWidget);
      expect(find.text('Lembretes de Meet & Greet'), findsOneWidget);
      expect(find.text('Resultado e encerramento'), findsOneWidget);
      expect(find.byType(NotificationPreferenceRow), findsNWidgets(3));
      expect(find.byType(Switch), findsNWidgets(3));

      final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
      expect(switches[0].value, isTrue);
      expect(switches[1].value, isTrue);
      expect(switches[2].value, isFalse);
      expect(switches[0].activeTrackColor, isNotNull);
    },
  );

  // --- red ---
  test('CF-209 flag não liga hub CF-166 nem CF-211/208/213', () {
    expect(CfTempMocks.useNotificationCategoryPrintFixtures, isFalse);
    expect(CfTempMocks.useMeetGreetNotifPrintFixtures, isFalse);
    expect(CfTempMocks.useInteractionsNotifPrintFixtures, isFalse);
    expect(CfTempMocks.useMembershipNotifPrintFixtures, isTrue);
    expect(CfTempMocks.useArtistsNotifPrintFixtures, isTrue);
    expect(CfTempMocks.useNotificationPrefFixtures, isFalse);
  });

  test('CF-209 categoria inválida não resolve grupo', () {
    expect(notificationGroupById('meet-typo'), isNull);
    expect(notificationGroupById(''), isNull);
  });

  testWidgets(
    'CF-209 erro de save é visualmente distinto do modo silencioso',
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
  test(
    'CF-209 normalize: chave ausente usa default print (resultado off)',
    () {
      final normalized = NotificationPreferencesService.normalize({
        NotificationPreferenceKeys.meetInvites: true,
        NotificationPreferenceKeys.meetReminders: true,
        // meet-results omitido → default false (print)
      });
      expect(normalized[NotificationPreferenceKeys.meetInvites], isTrue);
      expect(normalized[NotificationPreferenceKeys.meetReminders], isTrue);
      expect(normalized[NotificationPreferenceKeys.meetResults], isFalse);
    },
  );

  testWidgets('CF-209 switch anuncia rótulo sem foco duplo (A11Y-01)', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: NotificationPreferenceRow(
            title: 'Resultado e encerramento',
            description:
                'Quando o Meet terminar ou quando a janela de acesso mudar.',
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
    'CF-209 quiet mode: críticas (convites/lembretes) ficam ligáveis; resultado off',
    (tester) async {
      final group = notificationGroupById('meet')!;
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

      expect(find.text('Convites para Meet & Greet'), findsOneWidget);
      expect(find.text('Resultado e encerramento'), findsOneWidget);
      final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
      expect(switches.length, 3);
      // critical rows stay enabled under quiet mode
      expect(switches[0].onChanged, isNotNull);
      expect(switches[1].onChanged, isNotNull);
      // non-critical resultado disabled
      expect(switches[2].onChanged, isNull);
      expect(switches[2].value, isFalse);
    },
  );

  testWidgets('CF-209 descrição longa não comprime o switch', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: NotificationPreferenceRow(
            title: 'Lembretes de Meet & Greet',
            description:
                'Avisos antes da chamada, entrada na fila e início da sua vez. '
                'Texto ampliado para validar que a linha cresce em altura e o switch '
                'permanece alinhado à direita sem sobrepor a explicação.',
            value: true,
            enabled: true,
            showDivider: true,
            onChanged: (_) {},
          ),
        ),
      ),
    );
    await tester.pump();

    final switchBox = tester.getRect(find.byType(Switch));
    final titleBox = tester.getRect(find.text('Lembretes de Meet & Greet'));
    expect(switchBox.left, greaterThan(titleBox.right));
    expect(find.byType(Switch), findsOneWidget);
  });
}
