import 'package:crowdfans/components/post/post_avatar.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Linha compacta de resultado da busca de fã clube (CF-173).
///
/// Sem card/borda: avatar + nome alinhados, densidade do print de referência.
class FanClubSearchResultRow extends StatelessWidget {
  const FanClubSearchResultRow({
    super.key,
    required this.name,
    required this.avatarUrl,
    required this.onPressed,
  });

  final String name;
  final String avatarUrl;
  final VoidCallback onPressed;

  static const double avatarSize = 44;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            PostAvatar(url: avatarUrl, size: avatarSize),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
