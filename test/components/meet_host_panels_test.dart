import 'package:crowdfans/components/meet/meet_early_end_report_panel.dart';
import 'package:crowdfans/components/meet/meet_host_lobby_panel.dart';
import 'package:crowdfans/components/meet/meet_host_serving_panel.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/meet_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  MeetEventSnapshot snap({
    String status = 'lobby',
    int queueCount = 0,
    int lobbyRemainingSeconds = 180,
    bool canStartServing = false,
    bool pendingEarlyEndReport = false,
  }) {
    return MeetEventSnapshot(
      eventId: 'evt-1',
      artistUid: 'artist-1',
      artistName: 'Ana',
      status: status,
      lobbyEndsAt: 0,
      lobbyRemainingSeconds: lobbyRemainingSeconds,
      queueCount: queueCount,
      inQueue: false,
      hasMembership: true,
      canStartServing: canStartServing,
      pendingEarlyEndReport: pendingEarlyEndReport,
      opensWithoutMembership: true,
    );
  }

  testWidgets('gate: Iniciar Atendimento desabilitado até fila≥10 ou timer=0', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: MeetHostLobbyPanel(
            snapshot: snap(queueCount: 3, canStartServing: false),
            busy: false,
            onStartServing: () {},
            onFinish: () {},
          ),
        ),
      ),
    );

    final start = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Iniciar Atendimento'),
    );
    expect(start.onPressed, isNull);
    expect(find.textContaining('3'), findsWidgets);
  });

  testWidgets('gate liberado: Iniciar Atendimento chama callback', (
    tester,
  ) async {
    var started = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: MeetHostLobbyPanel(
            snapshot: snap(queueCount: 10, canStartServing: true),
            busy: false,
            onStartServing: () => started = true,
            onFinish: () {},
          ),
        ),
      ),
    );

    await tester.tap(find.text('Iniciar Atendimento'));
    expect(started, isTrue);
  });

  testWidgets('serving: Chamar próximo bloqueado com report pendente', (
    tester,
  ) async {
    var called = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: MeetHostServingPanel(
            snapshot: snap(
              status: 'serving',
              queueCount: 4,
              pendingEarlyEndReport: true,
            ),
            busy: false,
            onCallNext: () => called = true,
            onFinish: () {},
            onOpenReport: () {},
          ),
        ),
      ),
    );

    expect(find.textContaining('Report'), findsWidgets);
    final next = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Chamar próximo'),
    );
    expect(next.onPressed, isNull);
    expect(called, isFalse);
  });

  testWidgets('early-end report exige motivo antes de enviar', (tester) async {
    String? submitted;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: MeetEarlyEndReportPanel(
            busy: false,
            onSubmit: (reason, details) => submitted = reason,
          ),
        ),
      ),
    );

    expect(find.text('Enviar report'), findsOneWidget);
    await tester.tap(find.text('Enviar report'));
    expect(submitted, isNull);

    await tester.tap(find.text('Problema técnico'));
    await tester.pump();
    await tester.tap(find.text('Enviar report'));
    expect(submitted, 'Problema técnico');
  });
}
