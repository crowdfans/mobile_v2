import 'package:flutter/material.dart';

/// Paleta CrowdFans (espelho de `mobile/src/constants/theme.ts`).
abstract final class AppPalette {
  static const magenta500 = Color(0xFFFF27A0);
  static const purple50 = Color(0xFFF5F2FF);
  static const purple100 = Color(0xFFECE8FF);
  static const purple200 = Color(0xFFDAD4FF);
  static const purple300 = Color(0xFFC1B1FF);
  static const purple400 = Color(0xFFA285FF);
  static const purple500 = Color(0xFF7E49FF);
  static const purple600 = Color(0xFF7630F7);
  static const purple700 = Color(0xFF681EE3);
  static const purple800 = Color(0xFF5718BF);
  static const purple950 = Color(0xFF2C0B6A);
  static const blue400 = Color(0xFF48C7FF);
  static const blue700 = Color(0xFF0075FF);
  static const green400 = Color(0xFF24FB20);
  static const green700 = Color(0xFF028907);
  static const yellow400 = Color(0xFFFFE50D);
  static const yellow500 = Color(0xFFFFD600);
  static const orange600 = Color(0xFFFF7A00);
  static const orange700 = Color(0xFFCC5802);
  static const red400 = Color(0xFFFF6C64);
  static const red500 = Color(0xFFFF2C20);
  static const platinum50 = Color(0xFFF8FAFC);
  static const platinum100 = Color(0xFFF1F5F9);
  static const platinum200 = Color(0xFFE2E8F0);
  static const platinum300 = Color(0xFFCBD5E1);
  static const platinum400 = Color(0xFF94A3B8);
  static const platinum500 = Color(0xFF64748B);
  static const platinum600 = Color(0xFF475569);
  static const platinum700 = Color(0xFF334155);
  static const platinum800 = Color(0xFF1E293B);
  static const platinum900 = Color(0xFF0F172A);
  static const platinum950 = Color(0xFF020617);
}

/// Cores semânticas claro/escuro.
class AppColors {
  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.icon,
    required this.border,
    required this.primary,
    required this.primaryStrong,
    required this.buttonPrimary,
    required this.buttonPrimaryText,
    required this.danger,
    required this.inputBackground,
    required this.inputBorder,
    required this.overlay,
  });

  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color icon;
  final Color border;
  final Color primary;
  final Color primaryStrong;
  final Color buttonPrimary;
  final Color buttonPrimaryText;
  final Color danger;
  final Color inputBackground;
  final Color inputBorder;
  final Color overlay;

  static const light = AppColors(
    background: AppPalette.platinum50,
    surface: AppPalette.platinum50,
    surfaceAlt: AppPalette.platinum100,
    textPrimary: AppPalette.platinum900,
    textSecondary: AppPalette.platinum600,
    textTertiary: AppPalette.platinum500,
    icon: AppPalette.platinum700,
    border: AppPalette.platinum200,
    primary: AppPalette.purple500,
    primaryStrong: AppPalette.purple700,
    buttonPrimary: AppPalette.purple500,
    buttonPrimaryText: AppPalette.platinum50,
    danger: AppPalette.red500,
    inputBackground: AppPalette.platinum50,
    inputBorder: AppPalette.platinum200,
    overlay: Color(0x7A020617),
  );

  static const dark = AppColors(
    background: AppPalette.platinum950,
    surface: AppPalette.platinum950,
    surfaceAlt: AppPalette.platinum900,
    textPrimary: AppPalette.platinum50,
    textSecondary: AppPalette.platinum300,
    textTertiary: AppPalette.platinum400,
    icon: AppPalette.platinum300,
    border: AppPalette.platinum800,
    primary: AppPalette.purple400,
    primaryStrong: AppPalette.purple300,
    buttonPrimary: AppPalette.platinum50,
    buttonPrimaryText: AppPalette.platinum950,
    danger: AppPalette.red400,
    inputBackground: AppPalette.platinum950,
    inputBorder: AppPalette.platinum800,
    overlay: Color(0xB8020617),
  );
}

/// Accents do label "Login" (fã vs artista).
abstract final class AuthAccentPalette {
  static const fan = (start: AppPalette.orange600, end: AppPalette.yellow500);
  static const artist = (start: AppPalette.blue700, end: AppPalette.purple600);
}

/// Expõe [AppColors] a partir do [ThemeData].
class CrowdFansTheme extends ThemeExtension<CrowdFansTheme> {
  const CrowdFansTheme({required this.colors});

  final AppColors colors;

  static AppColors of(BuildContext context) {
    return Theme.of(context).extension<CrowdFansTheme>()?.colors ??
        AppColors.light;
  }

  @override
  CrowdFansTheme copyWith({AppColors? colors}) {
    return CrowdFansTheme(colors: colors ?? this.colors);
  }

  @override
  CrowdFansTheme lerp(ThemeExtension<CrowdFansTheme>? other, double t) {
    return this;
  }
}

/// Material 3 alinhado à paleta Superfã.
ThemeData buildCrowdFansTheme(Brightness brightness) {
  final colors = brightness == Brightness.dark
      ? AppColors.dark
      : AppColors.light;
  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    fontFamily: 'Inter',
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: colors.primary,
          brightness: brightness,
        ).copyWith(
          surface: colors.surface,
          primary: colors.primary,
          onPrimary: colors.buttonPrimaryText,
          error: colors.danger,
        ),
    scaffoldBackgroundColor: colors.background,
  );
  return base.copyWith(extensions: [CrowdFansTheme(colors: colors)]);
}
