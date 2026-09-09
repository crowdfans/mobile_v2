import 'package:crowdfans/components/home/create_menu_item_button.dart';
import 'package:crowdfans/components/ui/bottom_sheet_shell.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/state/auth_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Sheet de criação aberto pelo botão (+) da bottom nav.
class CreateMenuSheet extends ConsumerWidget {
  const CreateMenuSheet({
    super.key,
    required this.visible,
    required this.onClose,
    this.fanClubArtistId,
    this.fanClubArtistName,
    this.fanClubArtistAvatarUrl,
  });

  final bool visible;
  final VoidCallback onClose;
  final String? fanClubArtistId;
  final String? fanClubArtistName;
  final String? fanClubArtistAvatarUrl;

  void handleCreatePost(BuildContext context) {
    onClose();
    context.push(Pages.createPost);
  }

  void handleFanClubPost(BuildContext context) {
    onClose();
    context.push(
      Pages.fanClubComposeOf(
        artistId: fanClubArtistId,
        name: fanClubArtistName,
        avatarUrl: fanClubArtistAvatarUrl,
      ),
    );
  }

  void handleFanLetters(BuildContext context) {
    onClose();
    context.push(Pages.fanLetterGallery);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = CrowdFansTheme.of(context);
    final isArtist = ref.watch(authSessionProvider).profile?.isArtist == true;

    return BottomSheetShell(
      visible: visible,
      onClose: onClose,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: ColoredBox(
              color: colors.surface,
              child: Column(
                children: [
                  CreateMenuItemButton(
                    key: const Key('create-menu-fan-letters'),
                    asset: 'assets/icons/Communication/mail-01.svg',
                    label: 'Fan Letter',
                    onPressed: () => handleFanLetters(context),
                  ),
                  CreateMenuItemButton(
                    key: const Key('create-menu-fan-club-post'),
                    asset:
                        'assets/icons/Communication/message-heart-circle.svg',
                    label: 'Post Fã Clube',
                    onPressed: () => handleFanClubPost(context),
                    showDivider: true,
                  ),
                  if (isArtist)
                    CreateMenuItemButton(
                      key: const Key('create-menu-create-post'),
                      asset: 'assets/icons/General/edit-03.svg',
                      label: 'Post Home',
                      onPressed: () => handleCreatePost(context),
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
