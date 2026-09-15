import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// CF-153: Meet 1:1 (video_calls + /meet/request) removido; produto = Meet & Greet Virtual.
void main() {
  test('ApiUrls não expõe endpoints legado video-calls', () {
    final urls = File('lib/api/api_urls.dart').readAsStringSync();
    expect(urls, isNot(contains('video-calls')));
    expect(urls, isNot(contains('videoCalls')));
  });

  test('Pages não expõe rotas Meet 1:1', () {
    final pages = File('lib/constants/pages.dart').readAsStringSync();
    expect(pages, isNot(contains("meetRequest = '/meet/request'")));
    expect(pages, isNot(contains("meetWaiting = '/meet/waiting")));
    expect(pages, isNot(contains("meetRinging = '/meet/ringing")));
    expect(pages, isNot(contains("meetCall = '/meet/call/")));
    expect(pages, isNot(contains('meetRequestOf')));
    expect(pages, isNot(contains('meetWaitingOf')));
    expect(pages, isNot(contains('meetRingingOf')));
    expect(pages, isNot(contains('meetCallOf')));
    expect(pages, contains("meetLobby = '/meet/events"));
    expect(pages, contains("meetResult = '/meet/result'"));
  });

  test('arquivos legado Meet 1:1 foram removidos', () {
    final gone = [
      'lib/models/video_call.dart',
      'lib/services/video_call_service.dart',
      'lib/screens/meet/meet_request_screen.dart',
      'lib/screens/meet/meet_waiting_screen.dart',
      'lib/screens/meet/meet_ringing_screen.dart',
      'lib/screens/meet/meet_call_screen.dart',
      'test/models/video_call_test.dart',
    ];
    for (final path in gone) {
      expect(File(path).existsSync(), isFalse, reason: path);
    }
  });

  test('router não registra Meet 1:1', () {
    final router = File('lib/router/app_router.dart').readAsStringSync();
    expect(router, isNot(contains('MeetRequestScreen')));
    expect(router, isNot(contains('MeetWaitingScreen')));
    expect(router, isNot(contains('MeetRingingScreen')));
    expect(router, isNot(contains('MeetCallScreen')));
    expect(router, contains('MeetEventCallScreen'));
  });
}
