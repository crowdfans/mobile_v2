import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Folha de ações do perfil público (denunciar / bloquear).
class FanProfileActionsSheet extends StatelessWidget {
  const FanProfileActionsSheet({
    super.key,
    required this.displayName,
    required this.onReport,
    required this.onBlock,
  });

  final String displayName;
  final VoidCallback onReport;
  final VoidCallback onBlock;

  static Future<void> present(
    BuildContext context, {
    required String displayName,
    required VoidCallback onReport,
    required VoidCallback onBlock,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      builder: (context) => FanProfileActionsSheet(
        displayName: displayName,
        onReport: onReport,
        onBlock: onBlock,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              displayName.isEmpty ? 'Perfil' : displayName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              title: const Text('Denunciar'),
              onTap: () {
                Navigator.pop(context);
                onReport();
              },
            ),
            ListTile(
              title: Text('Bloquear', style: TextStyle(color: colors.danger)),
              onTap: () {
                Navigator.pop(context);
                onBlock();
              },
            ),
            ListTile(
              title: const Text('Cancelar'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
