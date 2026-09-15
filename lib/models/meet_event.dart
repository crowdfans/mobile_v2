/// Snapshot e call do Meet & Greet Virtual (`/api/v1/meet-events`, CF-149/CF-150).
class MeetEventSnapshot {
  const MeetEventSnapshot({
    required this.eventId,
    required this.artistUid,
    required this.artistName,
    required this.status,
    required this.lobbyEndsAt,
    required this.lobbyRemainingSeconds,
    required this.queueCount,
    required this.inQueue,
    required this.hasMembership,
    required this.canStartServing,
    required this.pendingEarlyEndReport,
    required this.opensWithoutMembership,
    this.queuePosition,
  });

  final String eventId;
  final String artistUid;
  final String artistName;
  final String status;
  final int lobbyEndsAt;
  final int lobbyRemainingSeconds;
  final int queueCount;
  final int? queuePosition;
  final bool inQueue;
  final bool hasMembership;
  final bool canStartServing;
  final bool pendingEarlyEndReport;
  final bool opensWithoutMembership;

  bool get isLobby => status == 'lobby';
  bool get isServing => status == 'serving';
  bool get isFinished => status == 'finished';

  factory MeetEventSnapshot.fromJson(Object? json) {
    final map = (json as Map?)?.cast<String, dynamic>() ?? {};
    return MeetEventSnapshot(
      eventId: map['eventId']?.toString() ?? '',
      artistUid: map['artistUid']?.toString() ?? '',
      artistName: map['artistName']?.toString() ?? '',
      status: map['status']?.toString() ?? '',
      lobbyEndsAt: (map['lobbyEndsAt'] as num?)?.toInt() ?? 0,
      lobbyRemainingSeconds:
          (map['lobbyRemainingSeconds'] as num?)?.toInt() ?? 0,
      queueCount: (map['queueCount'] as num?)?.toInt() ?? 0,
      queuePosition: (map['queuePosition'] as num?)?.toInt(),
      inQueue: map['inQueue'] == true,
      hasMembership: map['hasMembership'] == true,
      canStartServing: map['canStartServing'] == true,
      pendingEarlyEndReport: map['pendingEarlyEndReport'] == true,
      opensWithoutMembership: map['opensWithoutMembership'] == true,
    );
  }

  MeetEventSnapshot copyWithCountdown(int remaining) {
    return MeetEventSnapshot(
      eventId: eventId,
      artistUid: artistUid,
      artistName: artistName,
      status: status,
      lobbyEndsAt: lobbyEndsAt,
      lobbyRemainingSeconds: remaining < 0 ? 0 : remaining,
      queueCount: queueCount,
      queuePosition: queuePosition,
      inQueue: inQueue,
      hasMembership: hasMembership,
      canStartServing: canStartServing,
      pendingEarlyEndReport: pendingEarlyEndReport,
      opensWithoutMembership: opensWithoutMembership,
    );
  }
}

/// Call do Meet & Greet Virtual (ring 30s / active 90s).
class MeetCall {
  const MeetCall({
    required this.callId,
    required this.eventId,
    required this.fanUid,
    required this.artistUid,
    required this.status,
    required this.roomId,
    required this.authToken,
    required this.cometUid,
    required this.cometAppId,
    required this.cometRegion,
    required this.sandbox,
    required this.durationSeconds,
    required this.remainingSeconds,
    this.fanName = '',
    this.artistName = '',
    this.startedAt = 0,
    this.endedAt = 0,
    this.endedReason = '',
  });

  final String callId;
  final String eventId;
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
  final int durationSeconds;
  final int remainingSeconds;
  final int startedAt;
  final int endedAt;
  final String endedReason;

  bool get isRinging => status == 'ringing';
  bool get isActive => status == 'active';
  bool get isTerminal =>
      status == 'ended' || status == 'missed' || status == 'declined';

  factory MeetCall.fromJson(Object? json) {
    final map = (json as Map?)?.cast<String, dynamic>() ?? {};
    return MeetCall(
      callId: map['callId']?.toString() ?? '',
      eventId: map['eventId']?.toString() ?? '',
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
      durationSeconds: (map['durationSeconds'] as num?)?.toInt() ?? 90,
      remainingSeconds: (map['remainingSeconds'] as num?)?.toInt() ?? 90,
      startedAt: (map['startedAt'] as num?)?.toInt() ?? 0,
      endedAt: (map['endedAt'] as num?)?.toInt() ?? 0,
      endedReason: map['endedReason']?.toString() ?? '',
    );
  }

  MeetCall copyWithRemaining(int remaining) {
    return MeetCall(
      callId: callId,
      eventId: eventId,
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
      durationSeconds: durationSeconds,
      remainingSeconds: remaining,
      startedAt: startedAt,
      endedAt: endedAt,
      endedReason: endedReason,
    );
  }
}

/// Evento WS `meet-event.*` / `meet-call.*`.
class MeetRealtimeEvent {
  const MeetRealtimeEvent({
    required this.type,
    this.eventId,
    this.callId,
    this.status,
    this.remainingSeconds,
    this.call,
    this.snapshot,
  });

  final String type;
  final String? eventId;
  final String? callId;
  final String? status;
  final int? remainingSeconds;
  final MeetCall? call;
  final MeetEventSnapshot? snapshot;

  factory MeetRealtimeEvent.fromJson(Object? json) {
    final map = (json as Map?)?.cast<String, dynamic>() ?? {};
    final type = map['type']?.toString() ?? '';
    final data = map['data'];
    MeetCall? call;
    MeetEventSnapshot? snapshot;
    String? eventId;
    String? callId;
    String? status;
    int? remainingSeconds;

    if (data is Map) {
      final dataMap = data.cast<String, dynamic>();
      eventId = dataMap['eventId']?.toString();
      callId = dataMap['callId']?.toString();
      status = dataMap['status']?.toString();
      remainingSeconds = (dataMap['remainingSeconds'] as num?)?.toInt();
      if (callId != null && callId.isNotEmpty) {
        call = MeetCall.fromJson(dataMap);
      }
      if (dataMap.containsKey('queueCount') ||
          dataMap.containsKey('hasMembership')) {
        snapshot = MeetEventSnapshot.fromJson(dataMap);
      }
    }

    return MeetRealtimeEvent(
      type: type,
      eventId: eventId,
      callId: callId,
      status: status,
      remainingSeconds: remainingSeconds,
      call: call,
      snapshot: snapshot,
    );
  }

  bool get isMeetEvent => type.startsWith('meet-event.');
  bool get isMeetCall => type.startsWith('meet-call.');
  bool get isIncoming => type == 'meet-call.incoming';
}
