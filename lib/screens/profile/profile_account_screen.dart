import 'dart:typed_data';

import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/input/app_text_field.dart';
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
import 'package:crowdfans/utils/username_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

const _maxBioLength = 180;

class _AccountForm {
  const _AccountForm({
    required this.name,
    required this.username,
    required this.bio,
    required this.photoUrl,
  });

  final String name;
  final String username;
  final String bio;
  final String photoUrl;

  _AccountForm copyWith({
    String? name,
    String? username,
    String? bio,
    String? photoUrl,
  }) {
    return _AccountForm(
      name: name ?? this.name,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}

_AccountForm _buildForm(Profile profile) {
  return _AccountForm(
    name: profile.name,
    username: normalizeUsername(
      profile.displayName
          .replaceFirst(RegExp(r'^fan/'), '')
          .replaceFirst('@', ''),
    ),
    bio: profile.description,
    photoUrl: profile.photoUrl,
  );
}

/// Edição dos dados públicos do perfil (nome, username, bio, foto).
class ProfileAccountScreen extends ConsumerStatefulWidget {
  const ProfileAccountScreen({super.key});

  @override
  ConsumerState<ProfileAccountScreen> createState() =>
      _ProfileAccountScreenState();
}

class _ProfileAccountScreenState extends ConsumerState<ProfileAccountScreen> {
  Profile? _profile;
  _AccountForm? _form;
  _AccountForm? _initialForm;
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
      _form = _buildForm(stored);
      _initialForm = _form;
      _loading = false;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      handleLoad();
    });
  }

  Future<void> handleLoad() async {
    setState(() => _loading = _form == null);
    try {
      final profile = await ProfileService.getMyProfile();
      final form = _buildForm(profile);
      if (!mounted) {
        return;
      }
      ref.read(authSessionProvider.notifier).applyProfile(profile);
      setState(() {
        _profile = profile;
        _form = form;
        _initialForm = form;
        _error = null;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        if (_form == null) {
          _error = error.toString();
        }
      });
    }
  }

  void handleChangeName(String value) {
    final form = _form;
    if (form == null) {
      return;
    }
    setState(() {
      _form = form.copyWith(name: value);
      _error = null;
      _success = null;
    });
  }

  void handleChangeUsername(String value) {
    final form = _form;
    if (form == null) {
      return;
    }
    setState(() {
      _form = form.copyWith(username: normalizeUsername(value));
      _error = null;
      _success = null;
    });
  }

  void handleChangeBio(String value) {
    final form = _form;
    if (form == null) {
      return;
    }
    setState(() {
      _form = form.copyWith(
        bio: value.length > _maxBioLength
            ? value.substring(0, _maxBioLength)
            : value,
      );
      _error = null;
      _success = null;
    });
  }

  void handleChangePhotoUrl(String value) {
    final form = _form;
    if (form == null) {
      return;
    }
    setState(() {
      _localPhotoUri = null;
      _localPhotoBytes = null;
      _form = form.copyWith(photoUrl: value);
      _error = null;
      _success = null;
    });
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
      });
    } catch (error) {
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
    final form = _form;
    final initial = _initialForm;
    final profile = _profile;
    if (form == null || initial == null || profile == null || !canSave) {
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
      _success = null;
    });
    try {
      var photoUrl = form.photoUrl.trim();
      if (_localPhotoBytes != null && _localPhotoUri != null) {
        photoUrl = await MediaService.uploadBytes(
          bytes: _localPhotoBytes!,
          kind: MediaKind.avatar,
          contentType: MediaService.inferContentType(
            _localPhotoUri!,
            _localPhotoMime,
          ),
        );
      }
      final displayName = profile.isArtist
          ? profile.displayName
          : 'fan/${normalizeUsername(form.username)}';
      final name = profile.isArtist ? profile.name : form.name.trim();
      final bio = form.bio.trim();
      await ProfileService.updateMyProfile(
        name: name,
        displayName: displayName,
        description: bio,
        photoUrl: photoUrl,
      );
      final next = profile.copyWith(
        name: name,
        displayName: displayName,
        description: bio,
        photoUrl: photoUrl,
      );
      ref.read(authSessionProvider.notifier).applyProfile(next);
      final saved = form.copyWith(name: name, bio: bio, photoUrl: photoUrl);
      if (!mounted) {
        return;
      }
      setState(() {
        _profile = next;
        _form = saved;
        _initialForm = saved;
        _localPhotoUri = null;
        _localPhotoBytes = null;
        _saving = false;
        _success = 'Perfil atualizado com sucesso.';
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

  bool get nameIsValid {
    final form = _form;
    final profile = _profile;
    if (form == null) {
      return false;
    }
    return profile?.isArtist == true || form.name.trim().length >= 2;
  }

  bool get usernameIsValid {
    final form = _form;
    final profile = _profile;
    if (form == null) {
      return false;
    }
    return profile?.isArtist == true || isUsernameValid(form.username);
  }

  bool get photoUrlIsValid {
    final form = _form;
    if (form == null) {
      return false;
    }
    if (_localPhotoBytes != null) {
      return true;
    }
    final url = form.photoUrl.trim();
    return url.isEmpty ||
        RegExp(r'^https?:\/\/', caseSensitive: false).hasMatch(url);
  }

  bool get isDirty {
    final form = _form;
    final initial = _initialForm;
    if (form == null || initial == null) {
      return false;
    }
    return form.name != initial.name ||
        form.username != initial.username ||
        form.bio != initial.bio ||
        form.photoUrl != initial.photoUrl ||
        _localPhotoBytes != null;
  }

  bool get canSave {
    final form = _form;
    return form != null &&
        nameIsValid &&
        usernameIsValid &&
        photoUrlIsValid &&
        form.bio.length <= _maxBioLength &&
        isDirty &&
        !_saving;
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final form = _form;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            ProfileScreenHeader(
              title: 'Editar perfil',
              onBack: () => context.pop(),
            ),
            Expanded(
              child: _loading && form == null
                  ? const ProfileState(loading: true)
                  : form == null
                  ? ProfileState(
                      title: 'Perfil indisponível',
                      message: _error ?? 'Não foi possível carregar os dados.',
                      actionLabel: 'Tentar novamente',
                      onAction: handleLoad,
                    )
                  : _formBody(colors, form),
            ),
          ],
        ),
      ),
    );
  }

  Widget _formBody(AppColors colors, _AccountForm form) {
    final isArtist = _profile?.isArtist == true;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 34),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        Center(
          child: AccountAvatar(
            photoUrl: form.photoUrl,
            localBytes: _localPhotoBytes,
          ),
        ),
        const SizedBox(height: 12),
        AccountPhotoActions(
          hasLocalPhoto: _localPhotoBytes != null,
          onGallery: () => handlePick(ImageSource.gallery),
          onCamera: () => handlePick(ImageSource.camera),
        ),
        const SizedBox(height: 22),
        AppTextField(
          key: const ValueKey('account-name'),
          label: 'Nome',
          hint: 'Seu nome',
          initialValue: form.name,
          enabled: !isArtist,
          onChanged: handleChangeName,
          helper: !nameIsValid
              ? 'Informe pelo menos 2 caracteres.'
              : isArtist
              ? 'O nome oficial do artista não pode ser alterado por este formulário.'
              : null,
          helperColor: !nameIsValid ? colors.danger : null,
        ),
        const SizedBox(height: 16),
        AppTextField(
          key: const ValueKey('account-username'),
          label: 'Username',
          hint: 'username',
          initialValue: form.username,
          enabled: !isArtist,
          onChanged: handleChangeUsername,
          helper: isArtist
              ? 'O identificador oficial do artista permanece protegido.'
              : usernameIsValid
              ? 'Seu perfil será exibido como fan/${form.username}'
              : 'Use de 3 a 20 letras, números, ponto ou underline.',
          helperColor: usernameIsValid || isArtist ? null : colors.danger,
        ),
        const SizedBox(height: 16),
        AppTextField(
          key: const ValueKey('account-bio'),
          label: 'Bio',
          hint: 'Conte um pouco sobre você',
          maxLines: 5,
          initialValue: form.bio,
          onChanged: handleChangeBio,
          helper: '${form.bio.length}/$_maxBioLength caracteres',
        ),
        const SizedBox(height: 16),
        AppTextField(
          key: ValueKey('account-photo-${_localPhotoBytes == null}'),
          label: 'URL pública da foto',
          hint: 'https://...',
          keyboardType: TextInputType.url,
          initialValue: form.photoUrl,
          onChanged: handleChangePhotoUrl,
          helper: photoUrlIsValid
              ? null
              : 'Informe uma URL iniciada por http:// ou https://.',
          helperColor: photoUrlIsValid ? null : colors.danger,
        ),
        if (_error != null) ...[
          const SizedBox(height: 16),
          AccountFeedbackBanner(message: _error!, success: false),
        ],
        if (_success != null) ...[
          const SizedBox(height: 16),
          AccountFeedbackBanner(message: _success!, success: true),
        ],
        const SizedBox(height: 16),
        AppButton(
          label: _saving ? 'Salvando...' : 'Salvar alterações',
          disabled: !canSave,
          onPressed: handleSave,
        ),
      ],
    );
  }
}
