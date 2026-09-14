import 'package:crowdfans/models/video_call.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('VideoCall.fromJson mapeia DTO CF-31', () {
    final call = VideoCall.fromJson({
      'callId': 'abc',
      'fanUid': 'fan',
      'artistUid': 'artist',
      'fanName': 'Fan',
      'artistName': 'Artist',
      'status': 'ringing',
      'roomId': 'room',
      'authToken': 'tok',
      'cometUid': 'ufan',
      'cometAppId': 'sandbox',
      'cometRegion': 'us',
      'sandbox': true,
      'jamCoins': 60,
      'durationSeconds': 60,
      'remainingSeconds': 60,
    });

    expect(call.callId, 'abc');
    expect(call.isRinging, isTrue);
    expect(call.sandbox, isTrue);
    expect(call.jamCoins, 60);
  });

  test('VideoCallRealtimeEvent reconhece video-call.*', () {
    final event = VideoCallRealtimeEvent.fromJson({
      'type': 'video-call.tick',
      'data': {
        'callId': 'abc',
        'status': 'active',
        'remainingSeconds': 42,
      },
    });

    expect(event.isVideoCall, isTrue);
    expect(event.call?.remainingSeconds, 42);
  });
}
