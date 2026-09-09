import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:flutter/material.dart';

/// Botão "Editar Perfil" full-width do Meu Perfil.
class MeProfileActionsRow extends StatelessWidget {
  const MeProfileActionsRow({
    super.key,
    required this.onEditProfile,
  });

  final VoidCallback onEditProfile;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      key: const Key('profile-edit'),
      label: 'Editar Perfil',
      variant: AppButtonVariant.outline,
      onPressed: onEditProfile,
    );
  }
}
