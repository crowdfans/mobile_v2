import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Cabeçalho visual de post exclusivo com estado de desbloqueio.
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
    final colors = CrowdFansTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Conteudo exclusivo de @$memberName',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppPalette.purple700,
              ),
            ),
          ),
          if (!unlocked)
            GestureDetector(
              onTap: onPressUnlock,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppPalette.purple100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Desbloquear',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.purple700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
