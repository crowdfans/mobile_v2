import 'package:crowdfans/models/meet_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('MeetEventSnapshot.fromJson mapeia DTO CF-149', () {
    final snap = MeetEventSnapshot.fromJson({
      'eventId': 'evt-1',
      'artistUid': 'artist-1',
      'artistName': 'Ana',
      'status': 'lobby',
      'lobbyEndsAt': 1726400000,
      'lobbyRemainingSeconds': 240,
      'queueCount': 3,
      'queuePosition': 2,
      'inQueue': true,
      'hasMembership': true,
      'canStartServing': false,
      'pendingEarlyEndReport': false,
      'opensWithoutMembership': true,
    });

    expect(snap.eventId, 'evt-1');
    expect(snap.artistUid, 'artist-1');
    expect(snap.artistName, 'Ana');
    expect(snap.isLobby, isTrue);
    expect(snap.lobbyRemainingSeconds, 240);
    expect(snap.queueCount, 3);
    expect(snap.queuePosition, 2);
    expect(snap.inQueue, isTrue);
    expect(snap.hasMembership, isTrue);
    expect(snap.opensWithoutMembership, isTrue);
  });

  test('MeetCall.fromJson mapeia call 90s do meet-events', () {
    final call = MeetCall.fromJson({
      'callId': 'call-1',
      'eventId': 'evt-1',
      'fanUid': 'fan',
      'artistUid': 'artist',
      'fanName': 'Fan',
      'artistName': 'Ana',
      'status': 'ringing',
      'roomId': 'room',
      'authToken': 'tok',
      'cometUid': 'ufan',
      'cometAppId': 'sandbox',
      'cometRegion': 'us',
      'sandbox': true,
      'durationSeconds': 90,
      'remainingSeconds': 90,
    });

    expect(call.callId, 'call-1');
    expect(call.eventId, 'evt-1');
    expect(call.isRinging, isTrue);
    expect(call.durationSeconds, 90);
    expect(call.remainingSeconds, 90);
  });

  test('MeetRealtimeEvent reconhece meet-event.* e meet-call.*', () {
    final queue = MeetRealtimeEvent.fromJson({
      'type': 'meet-event.queue_updated',
      'data': {'eventId': 'evt-1', 'status': 'lobby'},
    });
    expect(queue.isMeetEvent, isTrue);
    expect(queue.isMeetCall, isFalse);
    expect(queue.eventId, 'evt-1');

    final incoming = MeetRealtimeEvent.fromJson({
      'type': 'meet-call.incoming',
      'data': {
        'callId': 'call-1',
        'eventId': 'evt-1',
        'status': 'ringing',
      },
    });
    expect(incoming.isMeetCall, isTrue);
    expect(incoming.isIncoming, isTrue);
    expect(incoming.callId, 'call-1');
  });
}
