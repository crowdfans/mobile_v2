import 'package:crowdfans/components/profile/profile_state.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/screens/profile/fan_score_screen.dart';
import 'package:crowdfans/services/profile_service.dart';
import 'package:crowdfans/state/auth_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// FanScore nas Configurações — mesmo layout do print CF-201 (Insights).
class ProfileFanScoreScreen extends ConsumerStatefulWidget {
  const ProfileFanScoreScreen({super.key});

  @override
  ConsumerState<ProfileFanScoreScreen> createState() =>
      _ProfileFanScoreScreenState();
}

class _ProfileFanScoreScreenState extends ConsumerState<ProfileFanScoreScreen> {
  String? _handle;
  var _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    handleResolveHandle();
  }

  void handleBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(Pages.profileSettings);
  }

  Future<void> handleResolveHandle() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    // TEMP CF-201: fixtures do print não dependem do handle real.
    if (CfTempMocks.useFanScoreFixtures && kUseCfTempMocks) {
      setState(() {
        _handle = 'demo';
        _loading = false;
      });
      return;
    }
    try {
      var profile = ref.read(authSessionProvider).profile;
      profile ??= await ProfileService.getMyProfile();
      final handle = ProfileService.normalizeFanHandle(
        profile.name.trim().isNotEmpty ? profile.name : profile.displayName,
      );
      if (!mounted) {
        return;
      }
      if (handle.isEmpty) {
        setState(() {
          _loading = false;
          _error = 'Handle inválido.';
        });
        return;
      }
      setState(() {
        _handle = handle;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = 'Não foi possível carregar o Fan Score.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final handle = _handle;
    if (!_loading && handle != null && handle.isNotEmpty) {
      return FanScoreScreen(
        fanHandle: handle,
        backFallback: Pages.profileSettings,
      );
    }
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            if (!_loading)
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: handleBack,
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: colors.textPrimary,
                    size: 20,
                  ),
                ),
              ),
            Expanded(
              child: _loading
                  ? const ProfileState(loading: true)
                  : ProfileState(
                      title: 'FanScore indisponível',
                      message: _error,
                      actionLabel: 'Tentar novamente',
                      onAction: handleResolveHandle,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
