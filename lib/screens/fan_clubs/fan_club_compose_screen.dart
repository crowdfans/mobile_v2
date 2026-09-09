import 'dart:typed_data';

import 'package:crowdfans/components/fan_club/fan_club_compose_artist.dart';
import 'package:crowdfans/components/fan_club/fan_club_selector_dropdown.dart';
import 'package:crowdfans/components/fan_club/fan_club_selector_field.dart';
import 'package:crowdfans/components/post/novo_post_composer_body.dart';
import 'package:crowdfans/components/post/novo_post_header.dart';
import 'package:crowdfans/components/post/novo_post_media_toolbar.dart';
import 'package:crowdfans/components/post/novo_post_secret_banner.dart';
import 'package:crowdfans/components/profile/profile_state.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:crowdfans/services/follow_service.dart';
import 'package:crowdfans/services/media_service.dart';
import 'package:crowdfans/services/post_service.dart';
import 'package:crowdfans/services/subscription_service.dart';
import 'package:crowdfans/state/auth_session.dart';
import 'package:crowdfans/utils/app_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

const _maxCharacters = 280;

/// Compose de post no fã clube — layout Twitter/Reddit dos prints CF-75.
class FanClubComposeScreen extends ConsumerStatefulWidget {
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
  ConsumerState<FanClubComposeScreen> createState() =>
      _FanClubComposeScreenState();
}

class _FanClubComposeScreenState extends ConsumerState<FanClubComposeScreen> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  FanClubComposeArtist? _selected;
  var _candidates = <FanClubComposeArtist>[];
  var _text = '';
  String? _imageUri;
  Uint8List? _imageBytes;
  String? _imageMime;
  var _loadingArtists = false;
  var _publishing = false;
  var _lockedArtist = false;
  var _clubSelectorOpen = false;
  var _isSecretMode = false;

  bool get _hasMedia =>
      (_imageUri ?? '').isNotEmpty ||
      (_imageBytes != null && _imageBytes!.isNotEmpty);

  bool get _canPublish =>
      _selected != null &&
      (_text.trim().isNotEmpty || _hasMedia) &&
      _text.length <= _maxCharacters &&
      !_publishing;

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

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> handleLoadArtists() async {
    setState(() => _loadingArtists = true);
    try {
      var subs = <Subscription>[];
      var follows = <ArtistFollow>[];
      try {
        subs = await SubscriptionService.listSubscriptions();
      } catch (_) {}
      try {
        follows = await FollowService.listFollows();
      } catch (_) {}
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

  void handleCancel() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(Pages.clubs);
  }

  void handleTextChange(String value) {
    setState(() => _text = value);
  }

  void handleToggleSecret() {
    setState(() => _isSecretMode = !_isSecretMode);
  }

  void handleToggleClubSelector() {
    if (_lockedArtist) {
      return;
    }
    setState(() {
      _clubSelectorOpen = !_clubSelectorOpen;
      if (_clubSelectorOpen) {
        _focusNode.unfocus();
      }
    });
  }

  void handleSelectArtist(FanClubComposeArtist artist) {
    setState(() {
      _selected = artist;
      _clubSelectorOpen = false;
    });
    _focusNode.requestFocus();
  }

  void handleComposerFocus() {
    if (_clubSelectorOpen) {
      setState(() => _clubSelectorOpen = false);
    }
  }

  void handleRemoveImage() {
    setState(() {
      _imageUri = null;
      _imageBytes = null;
      _imageMime = null;
    });
  }

  Future<void> handlePickFromGallery() async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (file == null) {
        return;
      }
      await _applyPickedImage(file);
    } catch (_) {
      await _showMediaError();
    }
  }

  Future<void> handleTakePhoto() async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (file == null) {
        return;
      }
      await _applyPickedImage(file);
    } catch (_) {
      await _showMediaError();
    }
  }

  Future<void> handlePickVideo() async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 2),
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
        _imageMime = file.mimeType ?? 'video/mp4';
      });
    } catch (_) {
      await _showMediaError();
    }
  }

  Future<void> _applyPickedImage(XFile file) async {
    final bytes = await file.readAsBytes();
    if (!mounted) {
      return;
    }
    setState(() {
      _imageUri = file.path.isNotEmpty ? file.path : file.name;
      _imageBytes = bytes;
      _imageMime = file.mimeType;
    });
  }

  Future<void> _showMediaError() async {
    if (!mounted) {
      return;
    }
    await AppAlert.show(
      context,
      title: 'Mídia',
      message: 'Não foi possível selecionar a mídia.',
    );
  }

  Future<void> handlePublish() async {
    final artist = _selected;
    if (artist == null || artist.id.isEmpty) {
      await AppAlert.show(
        context,
        title: 'Fã Clube',
        message: 'Escolha um fã clube para publicar.',
      );
      return;
    }
    if (!_canPublish) {
      return;
    }
    setState(() => _publishing = true);
    try {
      String? imageUri;
      String? videoUri;
      final isVideo = (_imageMime ?? '').startsWith('video/');
      if ((_imageUri ?? '').isNotEmpty) {
        final remote = await MediaService.resolveMediaUrl(
          uri: _imageUri!,
          kind: MediaKind.fanClub,
          mimeType: _imageMime,
          bytes: _imageBytes,
        );
        if (isVideo) {
          videoUri = remote;
        } else {
          imageUri = remote;
        }
      }
      final content = _text.trim();
      final type = videoUri != null
          ? PostType.video
          : imageUri == null
          ? PostType.text
          : PostType.image;
      await PostService.createPost(
        PostWriteRequest(
          type: type,
          text: content,
          imageUri: imageUri,
          videoUri: videoUri,
          targetArtistId: artist.id,
          isSecret: _isSecretMode,
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
    final profile = ref.watch(authSessionProvider).profile;
    final avatarUrl = profile?.photoUrl ?? '';
    final remaining = _maxCharacters - _text.length;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            NovoPostHeader(
              subtitle: 'Fã Clube',
              canSubmit: _canPublish,
              publishing: _publishing,
              onCancel: handleCancel,
              onPublish: handlePublish,
              showSecretToggle: true,
              isSecretMode: _isSecretMode,
              onToggleSecret: handleToggleSecret,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  if (_isSecretMode) ...[
                    const NovoPostSecretBanner(),
                    const SizedBox(height: 12),
                  ],
                  if (_loadingArtists && !_lockedArtist)
                    const ProfileState(loading: true)
                  else if (!_lockedArtist &&
                      _candidates.isEmpty &&
                      _selected == null)
                    const ProfileState(
                      title: 'Nenhum clube',
                      message: 'Siga um artista para publicar no fã clube.',
                    )
                  else ...[
                    FanClubSelectorField(
                      selected: _selected,
                      expanded: _clubSelectorOpen,
                      enabled: !_lockedArtist,
                      onPressed: handleToggleClubSelector,
                    ),
                    if (_clubSelectorOpen) ...[
                      const SizedBox(height: 8),
                      FanClubSelectorDropdown(
                        artists: _candidates,
                        selectedId: _selected?.id,
                        onSelect: handleSelectArtist,
                      ),
                    ],
                    const SizedBox(height: 24),
                    NovoPostComposerBody(
                      avatarUrl: avatarUrl,
                      controller: _textController,
                      focusNode: _focusNode,
                      onChanged: handleTextChange,
                      onFocus: handleComposerFocus,
                      imageBytes: _imageBytes,
                      imageUrl: _imageUri,
                      isVideo: (_imageMime ?? '').startsWith('video/'),
                      onRemoveImage: _hasMedia ? handleRemoveImage : null,
                    ),
                  ],
                ],
              ),
            ),
            NovoPostMediaToolbar(
              remainingCharacters: remaining,
              onPickGallery: handlePickFromGallery,
              onTakePhoto: handleTakePhoto,
              onPickVideo: handlePickVideo,
            ),
          ],
        ),
      ),
    );
  }
}
