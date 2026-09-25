import 'package:crowdfans/components/post/post_sheet_list_item.dart';
import 'package:crowdfans/components/ui/bottom_sheet_shell.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Rótulo do item Denunciar no menu do perfil (CF-192 print = “Denunciar”).
String artistProfileReportLabel() => 'Denunciar';

/// Menu do perfil do artista — composição Instagram do print (CF-192).
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
      Pages.fanClubCommunityOf(artistId, name: artistName),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheetShell(
      visible: visible,
      onClose: onClose,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PostSheetListItem(
              label: artistProfileReportLabel(),
              iconAsset: 'assets/icons/Maps & travel/flag-01.svg',
              onPressed: () => handleReport(context),
            ),
            PostSheetListItem(
              label: 'Abrir fã clube',
              iconAsset: 'assets/icons/Users/users-01.svg',
              onPressed: () => handleOpenFanClub(context),
              showDivider: true,
            ),
          ],
        ),
      ),
    );
  }
}
