import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Botão compacto (Galeria / Câmera) das telas de perfil.
class CompactAppButton extends StatelessWidget {
  const CompactAppButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 130),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.textPrimary,
          side: BorderSide(color: colors.border),
          backgroundColor: colors.surfaceAlt,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
