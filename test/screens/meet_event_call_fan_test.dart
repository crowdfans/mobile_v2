import 'package:crowdfans/components/meet/meet_event_call_chrome.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('chrome da call fã não tem Hang Up / Encerrar', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.dark),
        home: const Scaffold(
          body: MeetEventCallChrome(
            peerName: 'Ana',
            remainingSeconds: 90,
            joining: false,
            statusMessage: null,
            error: null,
          ),
        ),
      ),
    );

    expect(find.textContaining('01:30'), findsOneWidget);
    expect(find.text('Encerrar'), findsNothing);
    expect(find.text('Hang Up'), findsNothing);
    expect(find.byIcon(Icons.call_end), findsNothing);
  });
}
