import 'package:crowdfans/components/meet/meet_lobby_membership_paywall.dart';
import 'package:crowdfans/components/meet/meet_lobby_queue_panel.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/meet_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  MeetEventSnapshot snap({
    bool hasMembership = true,
    bool inQueue = false,
    int? queuePosition,
    int queueCount = 0,
    int lobbyRemainingSeconds = 180,
    String status = 'lobby',
  }) {
    return MeetEventSnapshot(
      eventId: 'evt-1',
      artistUid: 'artist-1',
      artistName: 'Ana',
      status: status,
      lobbyEndsAt: 0,
      lobbyRemainingSeconds: lobbyRemainingSeconds,
      queueCount: queueCount,
      queuePosition: queuePosition,
      inQueue: inQueue,
      hasMembership: hasMembership,
      canStartServing: false,
      pendingEarlyEndReport: false,
      opensWithoutMembership: true,
    );
  }

  testWidgets('sem membership mostra paywall e CTA assinar', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: MeetLobbyMembershipPaywall(
            artistName: 'Ana',
            onSubscribe: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.textContaining('Membership'), findsWidgets);
    expect(find.text('Assinar membership'), findsOneWidget);
    await tester.tap(find.text('Assinar membership'));
    expect(tapped, isTrue);
  });

  testWidgets('com membership mostra countdown e Entrar na fila', (
    tester,
  ) async {
    var joined = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: MeetLobbyQueuePanel(
            snapshot: snap(queueCount: 4),
            busy: false,
            onJoinQueue: () => joined = true,
            onLeaveQueue: () {},
          ),
        ),
      ),
    );

    expect(find.textContaining('03:00'), findsOneWidget);
    expect(find.textContaining('4'), findsWidgets);
    expect(find.text('Entrar na fila'), findsOneWidget);
    await tester.tap(find.text('Entrar na fila'));
    expect(joined, isTrue);
  });

  testWidgets('na fila mostra posição e Sair da fila', (tester) async {
    var left = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: MeetLobbyQueuePanel(
            snapshot: snap(inQueue: true, queuePosition: 2, queueCount: 5),
            busy: false,
            onJoinQueue: () {},
            onLeaveQueue: () => left = true,
          ),
        ),
      ),
    );

    expect(find.textContaining('posição 2'), findsOneWidget);
    expect(find.text('Sair da fila'), findsOneWidget);
    await tester.tap(find.text('Sair da fila'));
    expect(left, isTrue);
  });
}
