import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Pill único de membership no perfil do artista (rótulo Expo: + Seguir).
class ArtistProfileCtaPill extends StatelessWidget {
  const ArtistProfileCtaPill({
    super.key,
    required this.subscribed,
    required this.busy,
    required this.onPressed,
  });

  final bool subscribed;
  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final label = busy
        ? 'Aguarde...'
        : (subscribed ? 'Membership ✓' : '+ Seguir');
    return Material(
      color: subscribed ? colors.surfaceAlt : colors.primary,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: busy ? null : onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: subscribed
                    ? colors.textPrimary
                    : colors.buttonPrimaryText,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
