import 'package:crowdfans/components/post/post_avatar.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Cabeçalho da tela de comentários (CF-174): voltar + avatar + @handle.
class CommentThreadHeader extends StatelessWidget {
  const CommentThreadHeader({
    super.key,
    required this.onBack,
    this.author,
    this.handle,
    this.avatarUrl,
    this.onMenu,
  });

  final VoidCallback onBack;
  final String? author;
  final String? handle;
  final String? avatarUrl;
  final VoidCallback? onMenu;

  String get _displayHandle {
    final raw = (handle ?? '').trim();
    if (raw.isNotEmpty) {
      return raw.startsWith('@') ? raw : '@$raw';
    }
    final name = (author ?? '').trim();
    return name.isEmpty ? 'Comentários' : name;
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final hasIdentity =
        (author ?? '').trim().isNotEmpty || (handle ?? '').trim().isNotEmpty;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: SvgPicture.asset(
              'assets/icons/arrows/chevron-left.svg',
              width: 22,
              height: 22,
              colorFilter: ColorFilter.mode(
                colors.textPrimary,
                BlendMode.srcIn,
              ),
            ),
          ),
          if (hasIdentity) ...[
            PostAvatar(url: avatarUrl ?? '', size: 32),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _displayHandle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
            ),
          ] else
            Expanded(
              child: Text(
                'Comentários',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
            ),
          if (onMenu != null)
            IconButton(
              onPressed: onMenu,
              icon: Icon(Icons.more_horiz, color: colors.textPrimary),
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }
}
