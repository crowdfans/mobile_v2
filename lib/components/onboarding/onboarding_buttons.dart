import 'package:crowdfans/components/onboarding/onboarding_role_button.dart';
import 'package:flutter/material.dart';

/// Par de botões Superfã / Artista no onboarding.
class OnboardingButtons extends StatelessWidget {
  const OnboardingButtons({
    super.key,
    required this.onSuperfan,
    required this.onArtist,
    this.darkMode = false,
  });

  final VoidCallback onSuperfan;
  final VoidCallback onArtist;
  final bool darkMode;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OnboardingRoleButton(
          asset: 'assets/images/crowd.png',
          labelPrefix: 'Sou um ',
          labelStrong: 'Superfã',
          darkMode: darkMode,
          onPressed: onSuperfan,
        ),
        const SizedBox(height: 14),
        OnboardingRoleButton(
          asset: 'assets/images/mic.png',
          labelPrefix: 'Sou um ',
          labelStrong: 'Artista',
          darkMode: darkMode,
          onPressed: onArtist,
        ),
      ],
    );
  }
}
