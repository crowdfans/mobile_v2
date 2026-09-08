import 'dart:typed_data';

import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Avatar circular da tela de editar perfil.
class AccountAvatar extends StatelessWidget {
  const AccountAvatar({super.key, this.photoUrl, this.localBytes});

  final String? photoUrl;
  final Uint8List? localBytes;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    ImageProvider? image;
    if (localBytes != null && localBytes!.isNotEmpty) {
      image = MemoryImage(localBytes!);
    } else if (photoUrl != null && photoUrl!.isNotEmpty) {
      image = NetworkImage(photoUrl!);
    }
    return CircleAvatar(
      radius: 56,
      backgroundColor: colors.surfaceAlt,
      backgroundImage: image,
      child: image == null
          ? Icon(Icons.person, size: 52, color: colors.textTertiary)
          : null,
    );
  }
}
