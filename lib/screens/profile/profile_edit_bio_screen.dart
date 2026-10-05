import 'package:characters/characters.dart';
import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/input/app_text_field.dart';
import 'package:crowdfans/components/profile/account_feedback_banner.dart';
import 'package:crowdfans/components/profile/profile_bio_field_meta.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/components/profile/profile_state.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/profile.dart';
import 'package:crowdfans/services/profile_service.dart';
import 'package:crowdfans/state/auth_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const _maxBioLength = 180;

/// Página própria para editar a bio (CF-219).
class ProfileEditBioScreen extends ConsumerStatefulWidget {
  const ProfileEditBioScreen({super.key});

  @override
  ConsumerState<ProfileEditBioScreen> createState() =>
      _ProfileEditBioScreenState();
}

class _ProfileEditBioScreenState extends ConsumerState<ProfileEditBioScreen> {
  Profile? _profile;
  String _bio = '';
  String _initialBio = '';
  var _loading = true;
  var _saving = false;
  String? _error;
  String? _success;

  /// Contagem por grapheme (emoji / caracteres compostos).
  int get _bioCount => _bio.characters.length;

  @override
  void initState() {
    super.initState();
    final stored = ref.read(authSessionProvider).profile;
    if (stored != null) {
      _profile = stored;
      _bio = stored.description;
      _initialBio = stored.description;
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
        _bio = profile.description;
        _initialBio = profile.description;
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

  void handleChangeBio(String value) {
    final clamped = value.characters.length > _maxBioLength
        ? value.characters.take(_maxBioLength).toString()
        : value;
    setState(() {
      _bio = clamped;
      _error = null;
      _success = null;
    });
  }

  Future<void> handleSave() async {
    final profile = _profile;
    if (profile == null || !canSave) {
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
      _success = null;
    });
    try {
      final bio = _bio.trim();
      await ProfileService.updateMyProfile(
        name: profile.name,
        displayName: profile.displayName,
        description: bio,
        photoUrl: profile.photoUrl,
      );
      final next = profile.copyWith(description: bio);
      ref.read(authSessionProvider.notifier).applyProfile(next);
      if (!mounted) {
        return;
      }
      setState(() {
        _profile = next;
        _bio = bio;
        _initialBio = bio;
        _saving = false;
        _success = 'Bio atualizada com sucesso.';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      // Erro preserva o texto digitado e o cursor (campo não remonta).
      setState(() {
        _saving = false;
        _error = error.toString();
      });
    }
  }

  bool get canSave {
    return _profile != null &&
        _bio != _initialBio &&
        _bioCount <= _maxBioLength &&
        !_saving;
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            ProfileScreenHeader(
              title: 'Editar bio',
              onBack: () => context.pop(),
            ),
            Expanded(
              child: _loading && _profile == null
                  ? const ProfileState(loading: true)
                  : _profile == null
                  ? ProfileState(
                      title: 'Perfil indisponível',
                      message: _error ?? 'Não foi possível carregar os dados.',
                      actionLabel: 'Tentar novamente',
                      onAction: handleLoad,
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      children: [
                        Text(
                          'Sua bio',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        AppTextField(
                          // Remonta só quando a bio inicial do perfil muda (load).
                          key: ValueKey('edit-bio-field-$_initialBio'),
                          hint: 'Conte um pouco sobre você',
                          maxLines: 6,
                          maxLength: _maxBioLength,
                          initialValue: _bio,
                          onChanged: handleChangeBio,
                        ),
                        const SizedBox(height: 8),
                        ProfileBioFieldMeta(count: _bioCount),
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
                      ],
                    ),
            ),
            if (_profile != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: AppButton(
                  label: _saving ? 'Salvando...' : 'Salvar bio',
                  disabled: !canSave,
                  onPressed: handleSave,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
