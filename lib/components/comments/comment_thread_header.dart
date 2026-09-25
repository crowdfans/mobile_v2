import 'package:crowdfans/components/post/post_avatar.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Cabeçalho da tela de comentários (CF-174 / CF-194):
/// voltar + avatar (stack fã-clube) + nome/handle + menu.
class CommentThreadHeader extends StatelessWidget {
  const CommentThreadHeader({
    super.key,
    required this.onBack,
    this.author,
    this.handle,
    this.avatarUrl,
    this.clubAvatarUrl,
    this.clubName,
    this.onMenu,
  });

  final VoidCallback onBack;
  final String? author;
  final String? handle;
  final String? avatarUrl;
  final String? clubAvatarUrl;
  final String? clubName;
  final VoidCallback? onMenu;

  String get _displayHandle {
    final raw = (handle ?? '').trim();
    if (raw.isEmpty) {
      return '';
    }
    if (raw.startsWith('fan/') || raw.startsWith('@')) {
      return raw;
    }
    return raw;
  }

  bool get _isFanClub =>
      (clubName ?? '').trim().isNotEmpty ||
      (clubAvatarUrl ?? '').trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final name = (author ?? '').trim();
    final displayHandle = _displayHandle;
    final hasIdentity = name.isNotEmpty || displayHandle.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            tooltip: 'Voltar',
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
            _HeaderAvatarStack(
              primaryUrl: _isFanClub
                  ? ((clubAvatarUrl ?? '').trim().isNotEmpty
                        ? clubAvatarUrl!.trim()
                        : (avatarUrl ?? ''))
                  : (avatarUrl ?? ''),
              secondaryUrl: _isFanClub ? (avatarUrl ?? '') : null,
              background: colors.background,
            ),
            const SizedBox(width: 10),
            Expanded(
              // Print CF-194: só nome + handle na mesma linha (sem badge
              // “Fã-clube · …” — o stack de avatares já marca o contexto).
              child: Row(
                children: [
                  if (name.isNotEmpty)
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                  if (name.isNotEmpty && displayHandle.isNotEmpty)
                    const SizedBox(width: 6),
                  if (displayHandle.isNotEmpty)
                    Flexible(
                      child: Text(
                        displayHandle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.textTertiary,
                        ),
                      ),
                    ),
                ],
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
          IconButton(
            key: const Key('comment-thread-menu'),
            onPressed: onMenu,
            tooltip: 'Opções do post',
            icon: Icon(Icons.more_horiz, color: colors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _HeaderAvatarStack extends StatelessWidget {
  const _HeaderAvatarStack({
    required this.primaryUrl,
    required this.background,
    this.secondaryUrl,
  });

  final String primaryUrl;
  final String? secondaryUrl;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final secondary = (secondaryUrl ?? '').trim();
    if (secondary.isEmpty) {
      return PostAvatar(url: primaryUrl, size: 36);
    }
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          PostAvatar(url: primaryUrl, size: 32),
          Positioned(
            right: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: background, width: 2),
              ),
              child: PostAvatar(url: secondary, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}
