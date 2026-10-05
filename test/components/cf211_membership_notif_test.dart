import 'package:crowdfans/components/profile/notification_preference_error_banner.dart';
import 'package:crowdfans/components/profile/notification_preference_row.dart';
import 'package:crowdfans/components/profile/notification_preference_section.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/services/notification_preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CF-211 catálogo Membership: intro + ordem renovação → promo → saldo', () {
    final group = notificationGroupById('wallet')!;
    expect(group.title, 'Membership e Jam Coins');
    expect(
      group.pageIntro,
      'Ajuste tudo que envolve cobrança, saldo, promoções e alertas ligados ao seu membership.',
    );
    expect(group.navSubtitle, contains('Renovação'));
    expect(group.items.map((item) => item.title).toList(), [
      'Renovação de membership',
      'Promoções de Jam Coins',
      'Saldo e pagamentos',
    ]);
    expect(group.items.map((item) => item.description).toList(), [
      'Cobrança próxima, saldo insuficiente, renovação confirmada e cancelamento.',
      'Campanhas, bônus de recarga e ofertas especiais de Jam Coins.',
      'Recargas aprovadas, saldo baixo e pagamentos concluídos.',
    ]);
    expect(group.items[0].critical, isTrue);
    expect(group.items[1].critical, isFalse);
    expect(group.items[2].critical, isTrue);
  });

  test('CF-211 fixtures: renovação/saldo on, promo off (print)', () {
    expect(CfTempMocks.useMembershipNotifPrintFixtures, isTrue);
    final prefs = Cf208209211NotificationPrintFixtures.preferences();
    expect(prefs[NotificationPreferenceKeys.membershipRenewals], isTrue);
    expect(prefs[NotificationPreferenceKeys.jamCoinsPromos], isFalse);
    expect(prefs[NotificationPreferenceKeys.jamCoinsBalance], isTrue);
  });

  test('CF-211 rota da subpágina Membership', () {
    expect(
      Pages.profileNotificationCategory('wallet'),
      '/me/settings/notifications/wallet',
    );
  });

  testWidgets('CF-211 tela Membership: header, intro e switches do print', (
    tester,
  ) async {
    final group = notificationGroupById('wallet')!;
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

    expect(find.text('Membership e Jam Coins'), findsOneWidget);
    expect(
      find.text(
        'Ajuste tudo que envolve cobrança, saldo, promoções e alertas ligados ao seu membership.',
      ),
      findsOneWidget,
    );
    expect(find.text('Renovação de membership'), findsOneWidget);
    expect(find.text('Promoções de Jam Coins'), findsOneWidget);
    expect(find.text('Saldo e pagamentos'), findsOneWidget);
    expect(find.byType(NotificationPreferenceRow), findsNWidgets(3));
    expect(find.byType(Switch), findsNWidgets(3));

    final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
    expect(switches[0].value, isTrue);
    expect(switches[1].value, isFalse);
    expect(switches[2].value, isTrue);
    expect(switches[0].activeTrackColor, isNotNull);
  });

  testWidgets('CF-211 erro de save é visualmente distinto do modo silencioso', (
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

  testWidgets('CF-211 switch anuncia rótulo sem foco duplo', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: NotificationPreferenceRow(
            title: 'Promoções de Jam Coins',
            description: 'Campanhas, bônus de recarga e ofertas especiais de Jam Coins.',
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
}
