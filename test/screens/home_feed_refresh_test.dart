import 'package:crowdfans/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('feed home usa AlwaysScrollableScrollPhysics para pull-to-refresh vazio', () {
    expect(homeFeedScrollPhysics, isA<AlwaysScrollableScrollPhysics>());
  });
}
