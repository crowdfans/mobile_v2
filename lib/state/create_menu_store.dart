import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Estado compartilhado do sheet (+) da bottom nav.
class CreateMenuNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void openMenu() {
    state = true;
  }

  void closeMenu() {
    state = false;
  }
}

final createMenuProvider = NotifierProvider<CreateMenuNotifier, bool>(
  CreateMenuNotifier.new,
);
