import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

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
        _RoleButton(
          asset: 'assets/images/crowd.png',
          labelPrefix: 'Sou um ',
          labelStrong: 'Superfã',
          darkMode: darkMode,
          onPressed: onSuperfan,
        ),
        const SizedBox(height: 14),
        _RoleButton(
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

class _RoleButton extends StatelessWidget {
  const _RoleButton({
    required this.asset,
    required this.labelPrefix,
    required this.labelStrong,
    required this.darkMode,
    required this.onPressed,
  });

  final String asset;
  final String labelPrefix;
  final String labelStrong;
  final bool darkMode;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final bg = darkMode ? AppPalette.platinum950 : AppPalette.platinum50;
    final fg = darkMode ? AppPalette.platinum50 : AppPalette.platinum950;

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: const StadiumBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(asset, width: 16, height: 16),
            const SizedBox(width: 8),
            Text.rich(
              TextSpan(
                text: labelPrefix,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                children: [
                  TextSpan(
                    text: labelStrong,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
