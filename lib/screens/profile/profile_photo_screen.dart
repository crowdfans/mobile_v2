import 'dart:typed_data';

import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/profile/account_avatar.dart';
import 'package:crowdfans/components/profile/account_feedback_banner.dart';
import 'package:crowdfans/components/profile/account_photo_actions.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/components/profile/profile_state.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/profile.dart';
import 'package:crowdfans/services/media_service.dart';
import 'package:crowdfans/services/profile_service.dart';
import 'package:crowdfans/state/auth_session.dart';
import 'package:crowdfans/utils/app_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

/// Página própria para trocar a foto de perfil (CF-162 / CF-220).
class ProfilePhotoScreen extends ConsumerStatefulWidget {
  const ProfilePhotoScreen({super.key});

  @override
  ConsumerState<ProfilePhotoScreen> createState() => _ProfilePhotoScreenState();
}

class _ProfilePhotoScreenState extends ConsumerState<ProfilePhotoScreen> {
  Profile? _profile;
  String? _localPhotoUri;
  Uint8List? _localPhotoBytes;
  String? _localPhotoMime;
  var _loading = true;
  var _saving = false;
  String? _error;
  String? _success;

  @override
  void initState() {
    super.initState();
    final stored = ref.read(authSessionProvider).profile;
    if (stored != null) {
      _profile = stored;
      _loading = false;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      handleLoad();
    });
  }

  Future<void> handleLoad() async {
    setState(() => _loading = _profile == null);
    try {
      final profile = await ProfileService.getMyProfile();
      if (!mounted) {
        return;
      }
      ref.read(authSessionProvider.notifier).applyProfile(profile);
      setState(() {
        _profile = profile;
        _error = null;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        if (_profile == null) {
          _error = error.toString();
        }
      });
    }
  }

  Future<void> handlePick(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: source, imageQuality: 80);
      if (file == null) {
        return;
      }
      final bytes = await file.readAsBytes();
      if (!mounted) {
        return;
      }
      setState(() {
        _localPhotoUri = file.path.isNotEmpty ? file.path : file.name;
        _localPhotoBytes = bytes;
        _localPhotoMime = file.mimeType;
        _success = null;
        _error = null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      await AppAlert.show(
        context,
        title: 'Permissão necessária',
        message: source == ImageSource.camera
            ? 'Permita o acesso à câmera para tirar uma foto.'
            : 'Permita o acesso às fotos para escolher uma imagem.',
      );
    }
  }

  Future<void> handleSave() async {
    final profile = _profile;
    if (profile == null || _localPhotoBytes == null || _localPhotoUri == null) {
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
      _success = null;
    });
    try {
      final photoUrl = await MediaService.uploadBytes(
        bytes: _localPhotoBytes!,
        kind: MediaKind.avatar,
        contentType: MediaService.inferContentType(
          _localPhotoUri!,
          _localPhotoMime,
        ),
      );
      await ProfileService.updateMyProfile(
        name: profile.name,
        displayName: profile.displayName,
        description: profile.description,
        photoUrl: photoUrl,
      );
      final next = profile.copyWith(photoUrl: photoUrl);
      ref.read(authSessionProvider.notifier).applyProfile(next);
      if (!mounted) {
        return;
      }
      setState(() {
        _profile = next;
        _localPhotoUri = null;
        _localPhotoBytes = null;
        _saving = false;
        _success = 'Foto atualizada com sucesso.';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _saving = false;
        _error = error.toString();
      });
    }
  }

  bool get canSave =>
      _profile != null && _localPhotoBytes != null && !_saving;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final profile = _profile;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            ProfileScreenHeader(
              title: 'Foto de perfil',
              onBack: () => context.pop(),
            ),
            Expanded(
              child: _loading && profile == null
                  ? const ProfileState(loading: true)
                  : profile == null
                  ? ProfileState(
                      title: 'Perfil indisponível',
                      message: _error ?? 'Não foi possível carregar os dados.',
                      actionLabel: 'Tentar novamente',
                      onAction: handleLoad,
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 34),
                      children: [
                        Center(
                          child: AccountAvatar(
                            photoUrl: profile.photoUrl,
                            localBytes: _localPhotoBytes,
                          ),
                        ),
                        const SizedBox(height: 16),
                        AccountPhotoActions(
                          hasLocalPhoto: _localPhotoBytes != null,
                          onGallery: () => handlePick(ImageSource.gallery),
                          onCamera: () => handlePick(ImageSource.camera),
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 16),
                          AccountFeedbackBanner(
                            message: _error!,
                            success: false,
                          ),
                        ],
                        if (_success != null) ...[
                          const SizedBox(height: 16),
                          AccountFeedbackBanner(
                            message: _success!,
                            success: true,
                          ),
                        ],
                        if (canSave) ...[
                          const SizedBox(height: 16),
                          AppButton(
                            label: _saving ? 'Salvando...' : 'Salvar foto',
                            disabled: !canSave,
                            onPressed: handleSave,
                          ),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
