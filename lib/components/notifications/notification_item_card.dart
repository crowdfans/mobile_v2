import 'package:crowdfans/components/post/post_avatar.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/notifications_service.dart';
import 'package:flutter/material.dart';

/// Card de uma notificação (um ou vários avatares empilhados).
class NotificationItemCard extends StatelessWidget {
  const NotificationItemCard({
    super.key,
    required this.item,
    required this.onPressed,
  });

  final NotificationItem item;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final avatars = [
      for (final uri in item.avatarUris)
        if (uri.trim().isNotEmpty) uri,
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colors.border),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _avatars(avatars, colors),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            for (final segment in item.content)
                              TextSpan(
                                text: segment.text,
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 20 / 14,
                                  fontWeight: segment.accent
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                  color: colors.textPrimary,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.time,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _avatars(List<String> uris, AppColors colors) {
    if (uris.length <= 1) {
      return PostAvatar(url: uris.isEmpty ? '' : uris.first, size: 40);
    }
    final shown = uris.take(3).toList();
    const size = 40.0;
    final width = size + (shown.length - 1) * 14;
    return SizedBox(
      width: width,
      height: size,
      child: Stack(
        children: [
          for (var i = 0; i < shown.length; i++)
            Positioned(
              left: i * 14,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.surface, width: 2),
                ),
                child: PostAvatar(url: shown[i], size: 36),
              ),
            ),
        ],
      ),
    );
  }
}
