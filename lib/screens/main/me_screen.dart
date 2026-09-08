import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/state/auth_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Aba Perfil — dados do `GET /api/v1/profile` + logout.
class MeScreen extends ConsumerWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = CrowdFansTheme.of(context);
    final session = ref.watch(authSessionProvider);
    final profile = session.profile;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile?.displayName.isNotEmpty == true
                    ? profile!.displayName
                    : 'Eu',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                profile == null
                    ? 'Perfil ainda não carregou.'
                    : profile.isArtist
                        ? 'Conta de artista'
                        : 'Conta Superfã',
                style: TextStyle(fontSize: 16, color: colors.textSecondary),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () =>
                      ref.read(authSessionProvider.notifier).logout(),
                  child: const Text('Sair'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
