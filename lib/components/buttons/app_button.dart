import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Botão primário / outline / ghost (espelho do `ButtonComponent`).
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.disabled = false,
    this.loading = false,
    this.variant = AppButtonVariant.primary,
  });

  final String label;
  final VoidCallback onPressed;
  final bool disabled;
  final bool loading;
  final AppButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final enabled = !disabled && !loading;
    final text = loading ? 'Carregando...' : label;

    if (variant == AppButtonVariant.outline) {
      return SizedBox(
        width: double.infinity,
        height: 56,
        child: OutlinedButton(
          onPressed: enabled ? onPressed : null,
          style: OutlinedButton.styleFrom(shape: const StadiumBorder()),
          child: Text(text),
        ),
      );
    }

    if (variant == AppButtonVariant.ghost) {
      return SizedBox(
        width: double.infinity,
        height: 56,
        child: TextButton(
          onPressed: enabled ? onPressed : null,
          child: Text(text, style: const TextStyle(fontSize: 18)),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: enabled ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: colors.buttonPrimary,
          foregroundColor: colors.buttonPrimaryText,
          shape: const StadiumBorder(),
        ),
        child: Text(text, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}

enum AppButtonVariant { primary, outline, ghost }
