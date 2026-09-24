import 'package:flutter_test/flutter_test.dart';

String commentsClubQuery(String? clubName) {
  final club = (clubName ?? '').trim();
  if (club.isEmpty) {
    return '';
  }
  return 'club=${Uri.encodeQueryComponent(club)}';
}

void main() {
  test('comentários do fã-clube preservam club no query', () {
    expect(commentsClubQuery('Ana Castela'), contains('Ana'));
    expect(commentsClubQuery(null), isEmpty);
    expect(commentsClubQuery('  '), isEmpty);
  });
}
