import 'package:crowdfans/api/api_urls.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ApiUrls expõe rotas artista meet-events CF-151', () {
    expect(
      ApiUrls.meetEventStartServing,
      '/api/v1/meet-events/:eventId/start-serving',
    );
    expect(
      ApiUrls.meetEventCallNext,
      '/api/v1/meet-events/:eventId/call-next',
    );
    expect(ApiUrls.meetEventFinish, '/api/v1/meet-events/:eventId/finish');
    expect(ApiUrls.meetEventCallEnd, '/api/v1/meet-events/calls/:callId/end');
    expect(
      ApiUrls.meetEventCallEarlyEndReport,
      '/api/v1/meet-events/calls/:callId/early-end-report',
    );
  });

  test('Pages rotas host artista do Meet & Greet Virtual', () {
    expect(Pages.meetEventHostOf('evt-1'), '/meet/events/evt-1/host');
    expect(
      Pages.meetEventHostRingingOf('call-1', fanName: 'Bia'),
      '/meet/events/calls/call-1/host-ringing?name=Bia',
    );
    expect(
      Pages.meetEventCallOf('call-1', isArtist: true),
      '/meet/events/calls/call-1?role=artist',
    );
    expect(
      Pages.meetEventEarlyEndReportOf('call-1', eventId: 'evt-1'),
      '/meet/events/calls/call-1/early-end-report?eventId=evt-1',
    );
  });
}
