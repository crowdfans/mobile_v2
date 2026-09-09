import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Aviso de troca de telefone / sessões ainda sem backend.
class SecurityUnavailableCard extends StatelessWidget {
  const SecurityUnavailableCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.phonelink_lock, color: colors.textTertiary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Telefone e dispositivos',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'A troca de telefone e o gerenciamento de sessões aguardam endpoints e verificação SMS específicos. O legado apenas simulava essas operações.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
