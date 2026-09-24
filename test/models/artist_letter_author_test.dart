import 'package:flutter_test/flutter_test.dart';

String artistLetterAuthorLabel({
  required String fanDisplayName,
  required String fanHandle,
}) {
  final name = fanDisplayName.trim();
  if (name.isNotEmpty) {
    return name;
  }
  final handle = fanHandle.trim().replaceAll(RegExp(r'^@'), '');
  return handle.isEmpty ? 'Fã' : handle;
}

void main() {
  test('autoria da carta prioriza nome e cai para handle', () {
    expect(
      artistLetterAuthorLabel(fanDisplayName: 'Aline', fanHandle: 'aline'),
      'Aline',
    );
    expect(
      artistLetterAuthorLabel(fanDisplayName: '  ', fanHandle: '@pedro'),
      'pedro',
    );
    expect(
      artistLetterAuthorLabel(fanDisplayName: '', fanHandle: ''),
      'Fã',
    );
  });
}
