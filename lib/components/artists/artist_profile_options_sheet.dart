import 'package:crowdfans/components/post/post_sheet_list_item.dart';
import 'package:crowdfans/components/ui/bottom_sheet_shell.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Rótulo do item Denunciar no menu do perfil (CF-192 print = “Denunciar”).
String artistProfileReportLabel() => 'Denunciar';

/// Rótulo do item Abrir fã clube (CF-192 print).
String artistProfileOpenFanClubLabel() => 'Abrir fã clube';

/// Nome exibido no fluxo de denúncia; vazio → fallback genérico.
String artistProfileReportDisplayName(String artistName) {
  final name = artistName.trim();
  return name.isEmpty ? 'artista' : name;
}

/// Rota do fluxo de denúncia com objeto do perfil (CF-192).
String artistProfileReportRoute({
  required String artistId,
  required String artistName,
}) {
  final name = artistProfileReportDisplayName(artistName);
  return '${Pages.report}?context=artist-profile'
      '&targetId=${Uri.encodeQueryComponent(artistId)}'
      '&displayName=${Uri.encodeQueryComponent(name)}';
}

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
    onClose();
    context.push(
      artistProfileReportRoute(artistId: artistId, artistName: artistName),
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
      key: const Key('artist-profile-options-sheet'),
      visible: visible,
      onClose: onClose,
      child: Semantics(
        label: 'Menu do perfil',
        namesRoute: true,
        scopesRoute: true,
        explicitChildNodes: true,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PostSheetListItem(
                key: const Key('artist-profile-menu-report'),
                label: artistProfileReportLabel(),
                iconAsset: 'assets/icons/Maps & travel/flag-01.svg',
                onPressed: () => handleReport(context),
              ),
              PostSheetListItem(
                key: const Key('artist-profile-menu-fan-club'),
                label: artistProfileOpenFanClubLabel(),
                iconAsset: 'assets/icons/Users/users-01.svg',
                onPressed: () => handleOpenFanClub(context),
                showDivider: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
