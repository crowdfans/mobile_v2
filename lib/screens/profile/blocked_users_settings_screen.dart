import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/components/profile/profile_state.dart';
import 'package:crowdfans/components/profile/settings_restore_row.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/block_service.dart';
import 'package:crowdfans/utils/app_alert.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Usuários bloqueados, com opção de desbloquear.
class BlockedUsersSettingsScreen extends StatefulWidget {
  const BlockedUsersSettingsScreen({super.key});

  @override
  State<BlockedUsersSettingsScreen> createState() =>
      _BlockedUsersSettingsScreenState();
}

class _BlockedUsersSettingsScreenState
    extends State<BlockedUsersSettingsScreen> {
  var _users = <BlockedUser>[];
  var _loading = true;
  String? _error;
  String? _busyId;

  @override
  void initState() {
    super.initState();
    handleLoad();
  }

  Future<void> handleLoad() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final users = await BlockService.listBlockedUsers();
      if (!mounted) {
        return;
      }
      setState(() {
        _users = users;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = 'Não foi possível carregar os bloqueios.';
      });
    }
  }

  Future<void> handleUnblock(BlockedUser user) async {
    final ok = await AppAlert.confirm(
      context,
      title: 'Desbloquear',
      message: 'Desbloquear ${user.displayName}?',
      confirmLabel: 'Desbloquear',
    );
    if (!ok) {
      return;
    }
    setState(() => _busyId = user.userUid);
    try {
      await BlockService.unblockUser(user.userUid);
      await handleLoad();
    } catch (error) {
      if (mounted) {
        await AppAlert.show(
          context,
          title: 'Bloqueados',
          message: error.toString(),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busyId = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            ProfileScreenHeader(
              title: 'Bloqueados',
              onBack: () => context.pop(),
            ),
            Expanded(
              child: _loading
                  ? const ProfileState(loading: true)
                  : _error != null
                  ? ProfileState(
                      title: 'Erro',
                      message: _error,
                      actionLabel: 'Tentar novamente',
                      onAction: handleLoad,
                    )
                  : _users.isEmpty
                  ? const ProfileState(
                      title: 'Ninguém bloqueado',
                      message: 'Quem você bloquear deixa de aparecer no feed.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
                      itemCount: _users.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final user = _users[index];
                        return SettingsRestoreRow(
                          title: user.displayName,
                          subtitle: user.handle,
                          actionLabel: 'Desbloquear',
                          busy: _busyId == user.userUid,
                          onRestore: () => handleUnblock(user),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
