/// Chamada Meet 1:1 (CF-30 / API CF-31).
class VideoCall {
  const VideoCall({
    required this.callId,
    required this.fanUid,
    required this.artistUid,
    required this.status,
    required this.roomId,
    required this.authToken,
    required this.cometUid,
    required this.cometAppId,
    required this.cometRegion,
    required this.sandbox,
    required this.jamCoins,
    required this.durationSeconds,
    required this.remainingSeconds,
    this.fanName = '',
    this.artistName = '',
    this.startedAt = 0,
    this.endedAt = 0,
    this.endedReason = '',
    this.debited = false,
  });

  final String callId;
  final String fanUid;
  final String artistUid;
  final String fanName;
  final String artistName;
  final String status;
  final String roomId;
  final String authToken;
  final String cometUid;
  final String cometAppId;
  final String cometRegion;
  final bool sandbox;
  final int jamCoins;
  final int durationSeconds;
  final int remainingSeconds;
  final int startedAt;
  final int endedAt;
  final String endedReason;
  final bool debited;

  bool get isRinging => status == 'ringing';
  bool get isActive => status == 'active';
  bool get isTerminal =>
      status == 'ended' ||
      status == 'declined' ||
      status == 'missed' ||
      status == 'cancelled';

  factory VideoCall.fromJson(Object? json) {
    final map = (json as Map?)?.cast<String, dynamic>() ?? {};
    return VideoCall(
      callId: map['callId']?.toString() ?? '',
      fanUid: map['fanUid']?.toString() ?? '',
      artistUid: map['artistUid']?.toString() ?? '',
      fanName: map['fanName']?.toString() ?? '',
      artistName: map['artistName']?.toString() ?? '',
      status: map['status']?.toString() ?? '',
      roomId: map['roomId']?.toString() ?? '',
      authToken: map['authToken']?.toString() ?? '',
      cometUid: map['cometUid']?.toString() ?? '',
      cometAppId: map['cometAppId']?.toString() ?? '',
      cometRegion: map['cometRegion']?.toString() ?? 'us',
      sandbox: map['sandbox'] == true,
      jamCoins: (map['jamCoins'] as num?)?.toInt() ?? 60,
      durationSeconds: (map['durationSeconds'] as num?)?.toInt() ?? 60,
      remainingSeconds: (map['remainingSeconds'] as num?)?.toInt() ?? 60,
      startedAt: (map['startedAt'] as num?)?.toInt() ?? 0,
      endedAt: (map['endedAt'] as num?)?.toInt() ?? 0,
      endedReason: map['endedReason']?.toString() ?? '',
      debited: map['debited'] == true,
    );
  }

  VideoCall copyWithRemaining(int remaining) {
    return VideoCall(
      callId: callId,
      fanUid: fanUid,
      artistUid: artistUid,
      fanName: fanName,
      artistName: artistName,
      status: status,
      roomId: roomId,
      authToken: authToken,
      cometUid: cometUid,
      cometAppId: cometAppId,
      cometRegion: cometRegion,
      sandbox: sandbox,
      jamCoins: jamCoins,
      durationSeconds: durationSeconds,
      remainingSeconds: remaining,
      startedAt: startedAt,
      endedAt: endedAt,
      endedReason: endedReason,
      debited: debited,
    );
  }
}

/// Evento WS relacionado a video-call.*.
class VideoCallRealtimeEvent {
  const VideoCallRealtimeEvent({required this.type, this.call});

  final String type;
  final VideoCall? call;

  factory VideoCallRealtimeEvent.fromJson(Object? json) {
    final map = (json as Map?)?.cast<String, dynamic>() ?? {};
    final type = map['type']?.toString() ?? '';
    final data = map['data'];
    VideoCall? call;
    if (data is Map) {
      call = VideoCall.fromJson(data);
    }
    return VideoCallRealtimeEvent(type: type, call: call);
  }

  bool get isVideoCall => type.startsWith('video-call.');
}
