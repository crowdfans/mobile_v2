import 'package:crowdfans/components/post/post_sheet_list_item.dart';
import 'package:crowdfans/components/ui/bottom_sheet_shell.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Menu do perfil do artista (Denunciar / Abrir fã clube).
class ArtistProfileOptionsSheet extends StatelessWidget {
  const ArtistProfileOptionsSheet({
    super.key,
    required this.visible,
    required this.artistId,
    required this.artistName,
    required this.onClose,
    this.onOpenFanClub,
  });

  final bool visible;
  final String artistId;
  final String artistName;
  final VoidCallback onClose;
  final VoidCallback? onOpenFanClub;

  void handleReport(BuildContext context) {
    final name = artistName.trim().isEmpty ? 'artista' : artistName.trim();
    onClose();
    context.push(
      '${Pages.report}?context=artist-profile'
      '&targetId=${Uri.encodeQueryComponent(artistId)}'
      '&displayName=${Uri.encodeQueryComponent(name)}',
    );
  }

  void handleOpenFanClub(BuildContext context) {
    onClose();
    if (onOpenFanClub != null) {
      onOpenFanClub!();
      return;
    }
    context.push(
      Pages.fanClubCommunityOf(artistId: artistId, name: artistName),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final name = artistName.trim().isEmpty ? 'Artista' : artistName.trim();
    return BottomSheetShell(
      visible: visible,
      onClose: onClose,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              ),
              Semantics(
                button: true,
                label: 'Fechar menu de $name',
                child: IconButton(
                  onPressed: onClose,
                  icon: Icon(Icons.close, color: colors.textSecondary),
                ),
              ),
            ],
          ),
          Text(
            'Ações do perfil',
            style: TextStyle(fontSize: 13, color: colors.textSecondary),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ColoredBox(
              color: colors.surfaceAlt,
              child: Column(
                children: [
                  PostSheetListItem(
                    label: 'Denunciar perfil de $name',
                    onPressed: () => handleReport(context),
                  ),
                  PostSheetListItem(
                    label: 'Abrir fã clube',
                    onPressed: () => handleOpenFanClub(context),
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
