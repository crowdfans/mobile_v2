import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Estado visual reutilizável do módulo de perfil (loading / vazio / erro).
class ProfileState extends StatelessWidget {
  const ProfileState({
    super.key,
    this.loading = false,
    this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.align = TextAlign.center,
  });

  final bool loading;
  final String? title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final crossAxis = align == TextAlign.left || align == TextAlign.start
        ? CrossAxisAlignment.start
        : CrossAxisAlignment.center;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: crossAxis,
        children: [
          if (title != null)
            Text(
              title!,
              textAlign: align,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
          if (message != null) ...[
            const SizedBox(height: 8),
            Text(
              message!,
              textAlign: align,
              style: TextStyle(fontSize: 14, color: colors.textSecondary),
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            AppButton(label: actionLabel!, onPressed: onAction!),
          ],
        ],
      ),
    );
  }
}
