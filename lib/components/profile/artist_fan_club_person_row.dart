import 'package:crowdfans/components/post/post_avatar.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Linha de pessoa com ação (Remover / Adicionar) no hub Fã Clube.
class ArtistFanClubPersonRow extends StatelessWidget {
  const ArtistFanClubPersonRow({
    super.key,
    required this.displayName,
    required this.handle,
    required this.photoUrl,
    required this.actionLabel,
    required this.onAction,
    this.primaryAction = false,
    this.reason,
  });

  final String displayName;
  final String handle;
  final String photoUrl;
  final String actionLabel;
  final VoidCallback onAction;
  final bool primaryAction;
  final String? reason;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PostAvatar(url: photoUrl, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName.trim().isEmpty ? handle : displayName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    if (handle.trim().isNotEmpty)
                      Text(
                        handle.startsWith('fan/') ? handle : 'fan/$handle',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              Material(
                color: primaryAction ? colors.primary : colors.surfaceAlt,
                borderRadius: BorderRadius.circular(999),
                child: InkWell(
                  onTap: onAction,
                  borderRadius: BorderRadius.circular(999),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Text(
                      actionLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: primaryAction
                            ? colors.buttonPrimaryText
                            : colors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (reason != null && reason!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              reason!,
              style: TextStyle(
                fontSize: 13,
                height: 1.35,
                color: colors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
