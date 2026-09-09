import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:flutter/material.dart';

/// Ações Seguir / Fã Clube / Fan Letter / Membership no perfil do artista.
class ArtistProfileActions extends StatelessWidget {
  const ArtistProfileActions({
    super.key,
    required this.following,
    required this.subscribed,
    required this.togglingFollow,
    required this.onToggleFollow,
    required this.onOpenFanClub,
    required this.onFanLetter,
    required this.onSubscribe,
  });

  final bool following;
  final bool subscribed;
  final bool togglingFollow;
  final VoidCallback onToggleFollow;
  final VoidCallback onOpenFanClub;
  final VoidCallback onFanLetter;
  final VoidCallback onSubscribe;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppButton(
          label: togglingFollow
              ? 'Aguarde...'
              : (following ? 'Seguindo' : 'Seguir'),
          variant: following
              ? AppButtonVariant.outline
              : AppButtonVariant.primary,
          disabled: togglingFollow,
          onPressed: onToggleFollow,
        ),
        const SizedBox(height: 10),
        AppButton(
          label: 'Fã Clube',
          variant: AppButtonVariant.outline,
          onPressed: onOpenFanClub,
        ),
        const SizedBox(height: 10),
        AppButton(
          label: 'Fan Letter',
          variant: AppButtonVariant.outline,
          onPressed: onFanLetter,
        ),
        if (!subscribed) ...[
          const SizedBox(height: 10),
          AppButton(
            label: 'Assinar membership',
            variant: AppButtonVariant.outline,
            onPressed: onSubscribe,
          ),
        ],
      ],
    );
  }
}
