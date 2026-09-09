import 'dart:typed_data';

import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/fan_club/fan_club_compose_artist.dart';
import 'package:crowdfans/components/fan_club/fan_club_compose_artist_card.dart';
import 'package:crowdfans/components/fan_club/fan_club_compose_artist_pick_row.dart';
import 'package:crowdfans/components/fan_club/fan_club_compose_image_preview.dart';
import 'package:crowdfans/components/input/app_text_field.dart';
import 'package:crowdfans/components/post/create_post_image_picker.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/components/profile/profile_state.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:crowdfans/services/follow_service.dart';
import 'package:crowdfans/services/media_service.dart';
import 'package:crowdfans/services/post_service.dart';
import 'package:crowdfans/services/subscription_service.dart';
import 'package:crowdfans/utils/app_alert.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

/// Compose de post no fã clube (fã ou artista membro).
class FanClubComposeScreen extends StatefulWidget {
  const FanClubComposeScreen({
    super.key,
    this.artistId,
    this.artistName,
    this.avatarUrl,
  });

  final String? artistId;
  final String? artistName;
  final String? avatarUrl;

  @override
  State<FanClubComposeScreen> createState() => _FanClubComposeScreenState();
}

class _FanClubComposeScreenState extends State<FanClubComposeScreen> {
  late FanClubComposeArtist? _selected;
  var _candidates = <FanClubComposeArtist>[];
  var _text = '';
  String? _imageUri;
  Uint8List? _imageBytes;
  String? _imageMime;
  var _loadingArtists = false;
  var _publishing = false;
  var _lockedArtist = false;

  @override
  void initState() {
    super.initState();
    final seededId = (widget.artistId ?? '').trim();
    _lockedArtist = seededId.isNotEmpty;
    _selected = seededId.isEmpty
        ? null
        : FanClubComposeArtist(
            id: seededId,
            name: (widget.artistName ?? '').trim().isEmpty
                ? 'Artista'
                : widget.artistName!.trim(),
            avatarUrl: widget.avatarUrl ?? '',
          );
    if (!_lockedArtist) {
      _loadingArtists = true;
      handleLoadArtists();
    }
  }

  Future<void> handleLoadArtists() async {
    setState(() => _loadingArtists = true);
    try {
      var subs = <Subscription>[];
      var follows = <ArtistFollow>[];
      try {
        subs = await SubscriptionService.listSubscriptions();
      } catch (_) {
        // Sem memberships — a lista ainda pode vir dos follows.
      }
      try {
        follows = await FollowService.listFollows();
      } catch (_) {
        // Sem follows — mostra só as assinaturas ativas.
      }
      final merged = <String, FanClubComposeArtist>{};
      for (final row in subs.where((item) => item.isActive)) {
        merged[row.artistUid] = FanClubComposeArtist(
          id: row.artistUid,
          name: row.artistName,
        );
      }
      for (final follow in follows) {
        merged.putIfAbsent(
          follow.artistUid,
          () => FanClubComposeArtist(
            id: follow.artistUid,
            name: follow.artistName,
            avatarUrl: follow.avatarUrl,
          ),
        );
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _candidates = merged.values.toList();
        _loadingArtists = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _candidates = [];
        _loadingArtists = false;
      });
    }
  }

  void handleBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(Pages.clubs);
  }

  void handleTextChange(String value) {
    setState(() => _text = value);
  }

  void handleSelectArtist(FanClubComposeArtist artist) {
    setState(() => _selected = artist);
  }

  void handleClearArtist() {
    setState(() => _selected = null);
  }

  Future<void> handlePickImage() async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (file == null) {
        return;
      }
      final bytes = await file.readAsBytes();
      if (!mounted) {
        return;
      }
      setState(() {
        _imageUri = file.path.isNotEmpty ? file.path : file.name;
        _imageBytes = bytes;
        _imageMime = file.mimeType;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      await AppAlert.show(
        context,
        title: 'Imagem',
        message: 'Não foi possível selecionar a imagem.',
      );
    }
  }

  Future<void> handlePublish() async {
    final artist = _selected;
    if (artist == null || artist.id.isEmpty) {
      await AppAlert.show(
        context,
        title: 'Fã Clube',
        message: 'Escolha um artista para publicar.',
      );
      return;
    }
    final content = _text.trim();
    if (content.isEmpty) {
      await AppAlert.show(
        context,
        title: 'Fã Clube',
        message: 'Escreva algo para publicar.',
      );
      return;
    }
    setState(() => _publishing = true);
    try {
      String? imageUri;
      if ((_imageUri ?? '').isNotEmpty) {
        imageUri = await MediaService.resolveMediaUrl(
          uri: _imageUri!,
          kind: MediaKind.fanClub,
          mimeType: _imageMime,
          bytes: _imageBytes,
        );
      }
      await PostService.createPost(
        PostWriteRequest(
          type: imageUri == null ? PostType.text : PostType.image,
          text: content,
          imageUri: imageUri,
          targetArtistId: artist.id,
        ),
      );
      if (!mounted) {
        return;
      }
      context.go(
        Pages.fanClubCommunityOf(
          artist.id,
          name: artist.name,
          avatarUrl: artist.avatarUrl,
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      await AppAlert.show(
        context,
        title: 'Fã Clube',
        message: error.toString(),
      );
    } finally {
      if (mounted) {
        setState(() => _publishing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final selected = _selected;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            ProfileScreenHeader(title: 'Post no Fã Clube', onBack: handleBack),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  Text(
                    'Artista',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (selected != null)
                    FanClubComposeArtistCard(
                      artist: selected,
                      onChange: _lockedArtist ? null : handleClearArtist,
                    )
                  else if (_loadingArtists)
                    const ProfileState(loading: true)
                  else if (_candidates.isEmpty)
                    const ProfileState(
                      title: 'Nenhum clube',
                      message: 'Siga um artista para publicar no fã clube.',
                    )
                  else
                    for (final artist in _candidates)
                      FanClubComposeArtistPickRow(
                        artist: artist,
                        onPressed: () => handleSelectArtist(artist),
                      ),
                  if (selected != null) ...[
                    const SizedBox(height: 20),
                    AppTextField(
                      label: 'Conteúdo',
                      hint: 'O que você quer compartilhar com o clube?',
                      maxLines: 6,
                      onChanged: handleTextChange,
                    ),
                    const SizedBox(height: 16),
                    CreatePostImagePicker(
                      hasImage: (_imageUri ?? '').isNotEmpty,
                      onPressed: handlePickImage,
                    ),
                    if ((_imageBytes != null && _imageBytes!.isNotEmpty) ||
                        (_imageUri ?? '').startsWith('http')) ...[
                      const SizedBox(height: 12),
                      FanClubComposeImagePreview(
                        bytes: _imageBytes,
                        remoteUrl: _imageUri,
                      ),
                    ],
                  ],
                ],
              ),
            ),
            if (selected != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: AppButton(
                  label: 'Publicar',
                  loading: _publishing,
                  disabled: _text.trim().isEmpty,
                  onPressed: handlePublish,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
