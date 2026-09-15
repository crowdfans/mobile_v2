import 'package:crowdfans/components/meet/meet_event_call_chrome.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('chrome da call artista tem Encerrar', (tester) async {
    var hungUp = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.dark),
        home: Scaffold(
          body: MeetEventCallChrome(
            peerName: 'Bia',
            remainingSeconds: 75,
            joining: false,
            showHangUp: true,
            onHangUp: () => hungUp = true,
          ),
        ),
      ),
    );

    expect(find.text('Encerrar'), findsOneWidget);
    expect(find.byIcon(Icons.call_end), findsOneWidget);
    await tester.tap(find.byIcon(Icons.call_end));
    expect(hungUp, isTrue);
  });
}
