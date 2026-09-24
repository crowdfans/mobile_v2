import 'package:crowdfans/components/profile/account_photo_action_button.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Ações de galeria/câmera e aviso de upload pendente (CF-220).
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
        Text(
          'Escolha entre galeria ou câmera.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: colors.textTertiary,
          ),
        ),
        const SizedBox(height: 18),
        AccountPhotoActionButton(
          label: 'Selecionar foto da galeria',
          icon: Icons.image_outlined,
          onPressed: onGallery,
        ),
        const SizedBox(height: 12),
        AccountPhotoActionButton(
          label: 'Tirar foto',
          icon: Icons.photo_camera_outlined,
          onPressed: onCamera,
        ),
        if (hasLocalPhoto) ...[
          const SizedBox(height: 14),
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.border),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Text(
                'A imagem só substitui a atual depois que você salvar o upload.',
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
