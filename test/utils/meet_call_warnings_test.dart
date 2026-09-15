import 'package:crowdfans/utils/meet_call_warnings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dispara warning1 aos 60s e warning2 aos 80s decorridos', () {
    final tracker = MeetCallWarningTracker();

    expect(tracker.consume(elapsedSeconds: 0), isEmpty);
    expect(tracker.consume(elapsedSeconds: 59), isEmpty);
    expect(tracker.consume(elapsedSeconds: 60), [MeetCallWarning.audio1]);
    expect(tracker.consume(elapsedSeconds: 60), isEmpty);
    expect(tracker.consume(elapsedSeconds: 79), isEmpty);
    expect(tracker.consume(elapsedSeconds: 80), [MeetCallWarning.audio2]);
    expect(tracker.consume(elapsedSeconds: 90), isEmpty);
  });

  test('elapsed a partir de remaining (90s) alinha warnings', () {
    expect(MeetCallWarningTracker.elapsedFromRemaining(90, 90), 0);
    expect(MeetCallWarningTracker.elapsedFromRemaining(90, 30), 60);
    expect(MeetCallWarningTracker.elapsedFromRemaining(90, 10), 80);
  });
}
