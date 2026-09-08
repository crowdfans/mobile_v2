import 'package:crowdfans/components/buttons/compact_app_button.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Ações de galeria/câmera e aviso de upload pendente.
class AccountPhotoActions extends StatelessWidget {
  const AccountPhotoActions({
    super.key,
    required this.hasLocalPhoto,
    required this.onGallery,
    required this.onCamera,
  });

  final bool hasLocalPhoto;
  final VoidCallback onGallery;
  final VoidCallback onCamera;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CompactAppButton(label: 'Galeria', onPressed: onGallery),
            const SizedBox(width: 8),
            CompactAppButton(label: 'Câmera', onPressed: onCamera),
          ],
        ),
        if (hasLocalPhoto) ...[
          const SizedBox(height: 12),
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.border),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Text(
                'A imagem será enviada ao salvar o perfil.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: colors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
