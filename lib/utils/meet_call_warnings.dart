/// Beeps de aviso da call 90s (KB CF-A-21: 60s / 80s decorridos).
enum MeetCallWarning { audio1, audio2 }

/// Rastreia quais avisos já tocaram nesta call.
class MeetCallWarningTracker {
  var _played1 = false;
  var _played2 = false;

  /// Segundos decorridos a partir de duration/remaining.
  static int elapsedFromRemaining(int durationSeconds, int remainingSeconds) {
    final elapsed = durationSeconds - remainingSeconds;
    return elapsed < 0 ? 0 : elapsed;
  }

  /// Devolve os avisos que devem tocar neste tick (no máximo um por marco).
  List<MeetCallWarning> consume({required int elapsedSeconds}) {
    final out = <MeetCallWarning>[];
    if (!_played1 && elapsedSeconds >= 60) {
      _played1 = true;
      out.add(MeetCallWarning.audio1);
    }
    if (!_played2 && elapsedSeconds >= 80) {
      _played2 = true;
      out.add(MeetCallWarning.audio2);
    }
    return out;
  }
}
