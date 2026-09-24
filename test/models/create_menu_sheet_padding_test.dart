import 'package:crowdfans/components/home/create_menu_sheet.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('create menu reserva respiro além da área segura', () {
    expect(createMenuSheetExtraBottom(34), 12);
    expect(createMenuSheetExtraBottom(0), 20);
    expect(createMenuSheetExtraBottom(8), 20);
  });
}
