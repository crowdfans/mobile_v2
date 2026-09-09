import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Selo de membership (ícone + meses), igual ao PDF.
class MembershipBadge extends StatelessWidget {
  const MembershipBadge({super.key, this.label, this.tier});

  final String? label;
  final String? tier;

  @override
  Widget build(BuildContext context) {
    final visuals = _visualsFor(_resolveTier(tier, label));
    final showLabel = (label ?? '').trim().isNotEmpty;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: visuals.colors,
        ),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: visuals.borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: SizedBox(
          height: 24,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/logo/badgelogo.svg',
                width: 10,
                height: 10,
                colorFilter: ColorFilter.mode(
                  visuals.iconTint,
                  BlendMode.srcIn,
                ),
              ),
              if (showLabel) ...[
                const SizedBox(width: 4),
                Text(
                  label!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: visuals.textColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

String _resolveTier(String? tier, String? label) {
  final normalized = (tier ?? '').trim().toLowerCase();
  const known = {'1month', '3month', '6month', '9month', '12month'};
  if (known.contains(normalized)) {
    return normalized;
  }
  if (normalized == 'gold') {
    return '12month';
  }
  if (normalized == 'magenta') {
    return '9month';
  }
  final months = int.tryParse(label ?? '') ?? 0;
  if (months >= 12) {
    return '12month';
  }
  if (months >= 9) {
    return '9month';
  }
  if (months >= 6) {
    return '6month';
  }
  if (months >= 3) {
    return '3month';
  }
  return '1month';
}

({
  List<Color> colors,
  Color borderColor,
  Color textColor,
  Color iconTint,
})
_visualsFor(String tier) {
  return switch (tier) {
    '3month' => (
      colors: const [AppPalette.blue300, AppPalette.blue50],
      borderColor: AppPalette.blue200,
      textColor: AppPalette.blue950,
      iconTint: AppPalette.blue950,
    ),
    '6month' => (
      colors: const [AppPalette.red300, AppPalette.red100],
      borderColor: AppPalette.red200,
      textColor: AppPalette.red950,
      iconTint: AppPalette.red950,
    ),
    '9month' => (
      colors: const [AppPalette.magenta300, AppPalette.magenta100],
      borderColor: AppPalette.magenta200,
      textColor: AppPalette.magenta950,
      iconTint: AppPalette.magenta950,
    ),
    '12month' => (
      colors: const [AppPalette.orange300, AppPalette.orange50],
      borderColor: AppPalette.orange200,
      textColor: AppPalette.orange950,
      iconTint: AppPalette.orange950,
    ),
    _ => (
      colors: const [AppPalette.purple200, AppPalette.purple50],
      borderColor: AppPalette.purple300,
      textColor: AppPalette.purple950,
      iconTint: AppPalette.purple950,
    ),
  };
}
