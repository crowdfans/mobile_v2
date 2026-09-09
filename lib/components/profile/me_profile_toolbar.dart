import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Título "Meu Perfil" com atalhos de posts e settings.
class MeProfileToolbar extends StatelessWidget {
  const MeProfileToolbar({
    super.key,
    required this.onMyPosts,
    required this.onSettings,
  });

  final VoidCallback onMyPosts;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          Text(
            'Meu Perfil',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const Spacer(),
          IconButton(
            key: const Key('profile-my-posts-icon'),
            tooltip: 'Meus posts',
            onPressed: onMyPosts,
            icon: Icon(Icons.grid_view, color: colors.textPrimary),
          ),
          IconButton(
            key: const Key('profile-settings'),
            tooltip: 'Configurações',
            onPressed: onSettings,
            icon: Icon(Icons.settings, color: colors.textPrimary),
          ),
        ],
      ),
    );
  }
}
