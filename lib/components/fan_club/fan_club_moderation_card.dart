import 'package:crowdfans/components/post/post_avatar.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Card de contestação, aviso ou expulsão no painel de moderação.
class FanClubModerationCard extends StatelessWidget {
  const FanClubModerationCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.photoUrl = '',
    this.statusLabel,
    this.body,
    this.severityLabel,
    this.onApprove,
    this.onReject,
    this.busy = false,
  });

  final String title;
  final String subtitle;
  final String photoUrl;
  final String? statusLabel;
  final String? body;
  final String? severityLabel;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final approveLabel = 'Aceitar';
    final rejectLabel = 'Recusar';
    return Semantics(
      container: true,
      label: [
        title,
        if (subtitle.isNotEmpty) subtitle,
        if ((statusLabel ?? '').isNotEmpty) statusLabel!,
        if ((severityLabel ?? '').isNotEmpty) severityLabel!,
        if ((body ?? '').isNotEmpty) body!,
      ].join('. '),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PostAvatar(url: photoUrl, size: 44),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: colors.textPrimary,
                          ),
                        ),
                        if (subtitle.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.textTertiary,
                            ),
                          ),
                        ],
                        if ((statusLabel ?? '').isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            statusLabel!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: colors.primary,
                            ),
                          ),
                        ],
                        if ((severityLabel ?? '').isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            severityLabel!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if ((body ?? '').isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  body!,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: colors.textSecondary,
                  ),
                ),
              ],
              if (onApprove != null || onReject != null) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    if (onApprove != null)
                      Expanded(
                        child: Semantics(
                          button: true,
                          label: '$approveLabel $title',
                          child: SizedBox(
                            height: 44,
                            child: FilledButton(
                              onPressed: busy ? null : onApprove,
                              style: FilledButton.styleFrom(
                                backgroundColor: colors.buttonPrimary,
                                foregroundColor: colors.buttonPrimaryText,
                                shape: const StadiumBorder(),
                              ),
                              child: Text(
                                busy ? '...' : approveLabel,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (onApprove != null && onReject != null)
                      const SizedBox(width: 10),
                    if (onReject != null)
                      Expanded(
                        child: Semantics(
                          button: true,
                          label: '$rejectLabel $title',
                          child: SizedBox(
                            height: 44,
                            child: OutlinedButton(
                              onPressed: busy ? null : onReject,
                              style: OutlinedButton.styleFrom(
                                shape: const StadiumBorder(),
                                side: BorderSide(color: colors.border),
                              ),
                              child: Text(
                                rejectLabel,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
