import 'dart:typed_data';

import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Avatar circular grande da tela Foto de perfil (CF-220).
///
/// Raio ~64 espelha o preview do print YouTrack (diâmetro ~⅓ da largura).
class AccountAvatar extends StatelessWidget {
  const AccountAvatar({super.key, this.photoUrl, this.localBytes});

  final String? photoUrl;
  final Uint8List? localBytes;

  static const double radius = 64;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    ImageProvider? image;
    if (localBytes != null && localBytes!.isNotEmpty) {
      image = MemoryImage(localBytes!);
    } else if (photoUrl != null && photoUrl!.isNotEmpty) {
      image = NetworkImage(photoUrl!);
    }
    return Semantics(
      label: 'Pré-visualização da foto de perfil',
      image: true,
      child: CircleAvatar(
        key: const Key('profile-photo-avatar'),
        radius: radius,
        backgroundColor: colors.surfaceAlt,
        backgroundImage: image,
        child: image == null
            ? Icon(Icons.person, size: 52, color: colors.textTertiary)
            : null,
      ),
    );
  }
}
