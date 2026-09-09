import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:flutter/material.dart';

/// Atalhos Editar perfil / Meus posts no Meu Perfil.
class MeProfileActionsRow extends StatelessWidget {
  const MeProfileActionsRow({
    super.key,
    required this.onEditProfile,
    required this.onMyPosts,
  });

  final VoidCallback onEditProfile;
  final VoidCallback onMyPosts;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppButton(
            key: const Key('profile-edit'),
            label: 'Editar perfil',
            variant: AppButtonVariant.outline,
            onPressed: onEditProfile,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: AppButton(
            key: const Key('profile-my-posts'),
            label: 'Meus posts',
            onPressed: onMyPosts,
          ),
        ),
      ],
    );
  }
}
