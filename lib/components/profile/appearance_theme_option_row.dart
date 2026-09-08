import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/state/appearance_settings.dart';
import 'package:flutter/material.dart';

/// Linha de opção de tema (sistema / claro / escuro).
class AppearanceThemeOptionRow extends StatelessWidget {
  const AppearanceThemeOptionRow({
    super.key,
    required this.preference,
    required this.selected,
    required this.onPressed,
  });

  final AppearanceThemePreference preference;
  final bool selected;
  final VoidCallback onPressed;

  String get _title {
    return switch (preference) {
      AppearanceThemePreference.system => 'Seguir o sistema',
      AppearanceThemePreference.light => 'Claro',
      AppearanceThemePreference.dark => 'Escuro',
    };
  }

  String get _subtitle {
    return switch (preference) {
      AppearanceThemePreference.system => 'Usa a configuração do aparelho.',
      AppearanceThemePreference.light => 'Mantém o aplicativo com fundo claro.',
      AppearanceThemePreference.dark => 'Reduz o brilho em ambientes escuros.',
    };
  }

  IconData get _icon {
    return switch (preference) {
      AppearanceThemePreference.system => Icons.settings_brightness,
      AppearanceThemePreference.light => Icons.light_mode,
      AppearanceThemePreference.dark => Icons.dark_mode,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return InkWell(
      onTap: onPressed,
      child: ColoredBox(
        color: selected ? colors.surfaceAlt : colors.surface,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colors.surfaceAlt,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_icon, size: 21, color: colors.textSecondary),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 2,
                    color: selected ? colors.primary : colors.border,
                  ),
                ),
                child: selected
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: colors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
