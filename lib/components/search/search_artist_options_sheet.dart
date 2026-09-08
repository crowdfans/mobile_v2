import 'package:crowdfans/components/post/post_sheet_list_item.dart';
import 'package:crowdfans/components/ui/bottom_sheet_shell.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/search_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Sheet de opções sobre um artista nos resultados de busca.
class SearchArtistOptionsSheet extends StatelessWidget {
  const SearchArtistOptionsSheet({
    super.key,
    required this.visible,
    required this.artist,
    required this.onClose,
  });

  final bool visible;
  final ArtistSearchItem? artist;
  final VoidCallback onClose;

  void handleOpenProfile(BuildContext context) {
    final current = artist;
    onClose();
    if (current == null) {
      return;
    }
    context.push(Pages.artistProfile.replaceAll(':artistId', current.id));
  }

  void handleOpenFanClub(BuildContext context) {
    final current = artist;
    onClose();
    if (current == null) {
      return;
    }
    context.push(Pages.fanClubCommunity.replaceAll(':artistId', current.id));
  }

  void handleReport(BuildContext context) {
    final current = artist;
    onClose();
    if (current == null) {
      return;
    }
    context.push(
      '${Pages.report}?context=artist-profile'
      '&targetId=${Uri.encodeComponent(current.id)}'
      '&displayName=${Uri.encodeComponent(current.name)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return BottomSheetShell(
      visible: visible,
      onClose: onClose,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            artist?.name ?? 'Artista',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            artist?.handle ?? '',
            style: TextStyle(fontSize: 13, color: colors.textSecondary),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: ColoredBox(
              color: colors.surfaceAlt,
              child: Column(
                children: [
                  PostSheetListItem(
                    label: 'Ver perfil',
                    onPressed: () => handleOpenProfile(context),
                  ),
                  PostSheetListItem(
                    label: 'Fã Clube',
                    onPressed: () => handleOpenFanClub(context),
                    showDivider: true,
                  ),
                  PostSheetListItem(
                    label: 'Denunciar',
                    onPressed: () => handleReport(context),
                    showDivider: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
