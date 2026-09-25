import 'package:crowdfans/components/artists/artist_profile_options_sheet.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CF-192: rótulo curto do print', () {
    expect(artistProfileReportLabel(), 'Denunciar');
  });
}
