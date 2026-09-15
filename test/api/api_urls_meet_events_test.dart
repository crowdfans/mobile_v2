import 'package:crowdfans/api/api_urls.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ApiUrls expõe rotas meet-events CF-149', () {
    expect(ApiUrls.meetEvents, '/api/v1/meet-events');
    expect(ApiUrls.meetEvent, '/api/v1/meet-events/:eventId');
    expect(ApiUrls.meetEventJoinQueue, '/api/v1/meet-events/:eventId/join-queue');
    expect(
      ApiUrls.meetEventLeaveQueue,
      '/api/v1/meet-events/:eventId/leave-queue',
    );
    expect(ApiUrls.meetEventCall, '/api/v1/meet-events/calls/:callId');
    expect(
      ApiUrls.meetEventCallAnswer,
      '/api/v1/meet-events/calls/:callId/answer',
    );
    expect(
      ApiUrls.meetEventCallMiss,
      '/api/v1/meet-events/calls/:callId/miss',
    );
  });

  test('Pages rotas fã do Meet & Greet Virtual', () {
    expect(
      Pages.meetEventRingingOf('call-1', artistName: 'Ana'),
      '/meet/events/calls/call-1/ringing?name=Ana',
    );
    expect(Pages.meetEventCallOf('call-1'), '/meet/events/calls/call-1');
  });
}
