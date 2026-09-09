import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Faixa de post exclusivo desbloqueado (print CF-67).
class ExclusivePostMetaRow extends StatelessWidget {
  const ExclusivePostMetaRow({
    super.key,
    required this.memberName,
    required this.unlocked,
    this.onPressUnlock,
  });

  final String memberName;
  final bool unlocked;
  final VoidCallback? onPressUnlock;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chipBg = isDark ? AppPalette.purple950 : AppPalette.purple50;
    final chipFg = isDark ? AppPalette.purple300 : AppPalette.purple700;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _chip('Exclusivo', chipBg, chipFg),
        if (unlocked)
          _chip('Disponível para membros', chipBg, chipFg)
        else if (onPressUnlock != null)
          GestureDetector(
            onTap: onPressUnlock,
            child: _chip(
              'Desbloquear @$memberName',
              AppPalette.purple100,
              AppPalette.purple700,
            ),
          ),
      ],
    );
  }

  Widget _chip(String label, Color background, Color foreground) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: foreground,
          ),
        ),
      ),
    );
  }
}
