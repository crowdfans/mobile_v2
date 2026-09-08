import 'package:crowdfans/models/artist_register_form_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Estado compartilhado do fluxo de cadastro de artista.
class ArtistRegisterNotifier extends Notifier<ArtistRegisterFormData> {
  @override
  ArtistRegisterFormData build() => const ArtistRegisterFormData();

  void setFields(
    ArtistRegisterFormData Function(ArtistRegisterFormData) update,
  ) {
    state = update(state);
  }

  void reset() {
    state = const ArtistRegisterFormData();
  }
}

final artistRegisterProvider =
    NotifierProvider<ArtistRegisterNotifier, ArtistRegisterFormData>(
      ArtistRegisterNotifier.new,
    );
