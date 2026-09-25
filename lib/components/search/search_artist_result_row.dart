import 'package:crowdfans/components/post/post_avatar.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/search_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Linha de resultado da busca de artistas (print CF-240).
///
/// Avatar circular, nome + @handle + membros, badge #rank e menu ⋮ —
/// área de toque ≥ 48px sem comprimir metadados.
class SearchArtistResultRow extends StatelessWidget {
  const SearchArtistResultRow({
    super.key,
    required this.artist,
    required this.onPressed,
    this.onPressMore,
    this.position,
  });

  final ArtistSearchItem artist;
  final VoidCallback onPressed;
  final VoidCallback? onPressMore;
  final int? position;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final handle = artist.handle.trim().isEmpty
        ? ''
        : (artist.handle.startsWith('@')
            ? artist.handle
            : '@${artist.handle}');
    final members = artist.membersLabel.isNotEmpty
        ? artist.membersLabel
        : (artist.memberCount > 0 ? '${artist.memberCount} membros' : '');
    final pos = position ?? artist.rank;
    final semanticsLabel = [
      artist.name,
      if (handle.isNotEmpty) handle,
      if (members.isNotEmpty) members,
      if (pos != null && pos > 0) 'posição $pos',
    ].join('. ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Semantics(
        button: true,
        label: semanticsLabel,
        child: Material(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: colors.border.withValues(alpha: 0.85)),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onPressed,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 72),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
                child: Row(
                  children: [
                    PostAvatar(url: artist.avatarUri, size: 52),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            artist.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                          ),
                          if (handle.isNotEmpty)
                            Text(
                              handle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: colors.textSecondary,
                              ),
                            ),
                          if (members.isNotEmpty)
                            Text(
                              members,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.textTertiary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (pos != null && pos > 0)
                      Container(
                        margin: const EdgeInsets.only(right: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFE8EEF8),
                              colors.surfaceAlt,
                            ],
                          ),
                        ),
                        child: Text(
                          '#$pos',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                    if (onPressMore != null)
                      IconButton(
                        onPressed: onPressMore,
                        constraints: const BoxConstraints(
                          minWidth: 48,
                          minHeight: 48,
                        ),
                        icon: SvgPicture.asset(
                          'assets/icons/General/dots-vertical.svg',
                          width: 22,
                          height: 22,
                          colorFilter: ColorFilter.mode(
                            colors.icon,
                            BlendMode.srcIn,
                          ),
                        ),
                        tooltip: 'Opções de ${artist.name}',
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
