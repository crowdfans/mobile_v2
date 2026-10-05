import 'package:crowdfans/components/post/post_sheet_list_item.dart';
import 'package:crowdfans/components/ui/bottom_sheet_shell.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Rótulo do item Denunciar no menu do perfil (CF-192 print = “Denunciar”).
String artistProfileReportLabel() => 'Denunciar';

/// Rótulo Abrir fã clube (CF-192 print).
String artistProfileOpenFanClubLabel() => 'Abrir fã clube';

/// Ícone de denúncia (bandeira) — traço oficial do print.
const kArtistProfileReportIconAsset = 'assets/icons/Maps & travel/flag-01.svg';

/// Ícone Abrir fã clube (grupo) — traço oficial do print.
const kArtistProfileFanClubIconAsset = 'assets/icons/Users/users-01.svg';

/// Rota de denúncia com objeto do perfil (CF-192: fluxo seguinte sabe o alvo).
String artistProfileReportRoute({
  required String artistId,
  required String artistName,
}) {
  final id = artistId.trim();
  final name = artistName.trim().isEmpty ? 'artista' : artistName.trim();
  return '${Pages.report}?context=artist-profile'
      '&targetId=${Uri.encodeQueryComponent(id)}'
      '&displayName=${Uri.encodeQueryComponent(name)}';
}

/// Menu do perfil do artista — composição Instagram do print (CF-192).
///
/// Só ações de perfil (Denunciar + Abrir fã clube). Sem ações de post.
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
    final id = artistId.trim();
    onClose();
    if (id.isEmpty) {
      return;
    }
    context.push(
      artistProfileReportRoute(artistId: id, artistName: artistName),
    );
  }

  void handleOpenFanClub(BuildContext context) {
    final id = artistId.trim();
    onClose();
    if (id.isEmpty) {
      return;
    }
    if (onOpenFanClub != null) {
      onOpenFanClub!();
      return;
    }
    context.push(
      Pages.fanClubCommunityOf(id, name: artistName),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheetShell(
      visible: visible,
      onClose: onClose,
      panelColor: AppPalette.purple50,
      child: Semantics(
        label: 'Menu do perfil',
        namesRoute: true,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PostSheetListItem(
                label: artistProfileReportLabel(),
                iconAsset: kArtistProfileReportIconAsset,
                onPressed: () => handleReport(context),
              ),
              PostSheetListItem(
                label: artistProfileOpenFanClubLabel(),
                iconAsset: kArtistProfileFanClubIconAsset,
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
