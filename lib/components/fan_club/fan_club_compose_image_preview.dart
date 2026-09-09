import 'dart:typed_data';

import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Preview da imagem escolhida no compose do fã clube.
class FanClubComposeImagePreview extends StatelessWidget {
  const FanClubComposeImagePreview({super.key, this.bytes, this.remoteUrl});

  final Uint8List? bytes;
  final String? remoteUrl;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final local = bytes;
    final url = remoteUrl?.trim() ?? '';
    Widget image;
    if (local != null && local.isNotEmpty) {
      image = Image.memory(local, fit: BoxFit.cover);
    } else if (url.isNotEmpty) {
      image = Image.network(url, fit: BoxFit.cover);
    } else {
      return const SizedBox.shrink();
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ColoredBox(
        color: colors.surfaceAlt,
        child: SizedBox(width: double.infinity, height: 180, child: image),
      ),
    );
  }
}
