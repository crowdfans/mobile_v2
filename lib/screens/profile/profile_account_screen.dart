import 'package:crowdfans/components/profile/account_quick_setting_row.dart';
import 'package:crowdfans/components/profile/account_summary_row.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/components/profile/profile_state.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/models/profile.dart';
import 'package:crowdfans/services/profile_service.dart';
import 'package:crowdfans/state/auth_session.dart';
import 'package:crowdfans/utils/username_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Hub “Seu Perfil”: resumo + configurações rápidas (CF-162).
class ProfileAccountScreen extends ConsumerStatefulWidget {
  const ProfileAccountScreen({super.key});

  @override
  ConsumerState<ProfileAccountScreen> createState() =>
      _ProfileAccountScreenState();
}

class _ProfileAccountScreenState extends ConsumerState<ProfileAccountScreen> {
  Profile? _profile;
  var _loading = true;
  String? _error;

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
      if (_profile == null &&
          kUseCfTempMocks &&
          CfTempMocks.useProfileAccountFixtures) {
        setState(() {
          _profile = Cf162ProfileAccountFixtures.aline;
          _error = null;
          _loading = false;
        });
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

  String _usernameOf(Profile profile) {
    return normalizeUsername(
      profile.displayName
          .replaceFirst(RegExp(r'^fan/'), '')
          .replaceFirst('@', ''),
    );
  }

  String _publicHandle(Profile profile) {
    final username = _usernameOf(profile);
    if (profile.isArtist) {
      return profile.displayName.isNotEmpty
          ? profile.displayName
          : username;
    }
    return 'fan/$username';
  }

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
              title: 'Seu Perfil',
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
                  : _body(colors, profile),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(AppColors colors, Profile profile) {
    final username = _usernameOf(profile);
    Widget rowDivider() => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Divider(height: 1, thickness: 1, color: colors.border),
        );
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 34),
      children: [
        AccountSummaryRow(
          key: const Key('account-summary-name'),
          label: 'Nome',
          value: profile.name,
        ),
        rowDivider(),
        AccountSummaryRow(
          key: const Key('account-summary-username'),
          label: 'Nome de usuário',
          value: username,
        ),
        rowDivider(),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Text(
            'Configurações rápidas',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: colors.textTertiary,
            ),
          ),
        ),
        AccountQuickSettingRow(
          key: const Key('account-quick-bio'),
          title: 'Editar bio',
          subtitle: 'Atualize sua descrição de perfil',
          onTap: () => context.push(Pages.profileEditBio),
        ),
        rowDivider(),
        AccountQuickSettingRow(
          key: const Key('account-quick-photo'),
          title: 'Foto de perfil',
          subtitle: 'Trocar imagem da conta',
          onTap: () => context.push(Pages.profilePhoto),
        ),
        rowDivider(),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Seu perfil será exibido como ${_publicHandle(profile)}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: colors.textTertiary,
            ),
          ),
        ),
      ],
    );
  }
}
