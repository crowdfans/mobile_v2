import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

enum MembershipManageAction { pause, cancel }

/// Opção selecionável Pausar / Cancelar (CF-205) — só muda UI ao tocar.
class MembershipManageOptionTile extends StatelessWidget {
  const MembershipManageOptionTile({
    super.key,
    required this.action,
    required this.selected,
    required this.onSelected,
  });

  final MembershipManageAction action;
  final bool selected;
  final ValueChanged<MembershipManageAction> onSelected;

  String get title => switch (action) {
    MembershipManageAction.pause => 'Pausar membership',
    MembershipManageAction.cancel => 'Cancelar membership',
  };

  String get description => switch (action) {
    MembershipManageAction.pause =>
      'Você interrompe a cobrança agora e pode retomar quando quiser sem decidir tudo hoje.',
    MembershipManageAction.cancel =>
      'Você encerra a assinatura e deixa de participar dos próximos ciclos desse artista.',
  };

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final border = selected ? AppPalette.blue300 : colors.border;
    final background = selected
        ? AppPalette.blue50.withValues(alpha: 0.65)
        : colors.surface;

    return Semantics(
      button: true,
      selected: selected,
      label: '$title. $description',
      child: InkWell(
        onTap: () => onSelected(action),
        borderRadius: BorderRadius.circular(16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border, width: selected ? 1.5 : 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    height: 18 / 13,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
