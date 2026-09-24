import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Ação outline da foto de perfil (galeria / câmera).
class AccountPhotoActionButton extends StatelessWidget {
  const AccountPhotoActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          shape: const StadiumBorder(),
          side: BorderSide(color: colors.border),
          foregroundColor: colors.textPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 18),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(icon, size: 22, color: colors.textPrimary),
          ],
        ),
      ),
    );
  }
}
