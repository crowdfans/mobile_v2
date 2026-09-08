import 'package:crowdfans/models/fan_register_form_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Estado compartilhado do fluxo de cadastro Superfã.
class FanRegisterNotifier extends Notifier<FanRegisterFormData> {
  @override
  FanRegisterFormData build() => const FanRegisterFormData();

  void setFields(FanRegisterFormData Function(FanRegisterFormData) update) {
    state = update(state);
  }

  void reset() {
    state = const FanRegisterFormData();
  }
}

final fanRegisterProvider =
    NotifierProvider<FanRegisterNotifier, FanRegisterFormData>(
      FanRegisterNotifier.new,
    );
