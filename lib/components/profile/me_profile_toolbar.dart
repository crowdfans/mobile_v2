import 'package:crowdfans/components/profile/me_jams_pill.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Título "Meu Perfil · fan/handle" com Jams e settings (print Superfã).
class MeProfileToolbar extends StatelessWidget {
  const MeProfileToolbar({
    super.key,
    required this.handle,
    required this.onJams,
    required this.onSettings,
  });

  final String handle;
  final VoidCallback onJams;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final clean = handle.trim().replaceAll(RegExp(r'^@'), '');
    final fanHandle = clean.isEmpty ? '' : 'fan/$clean';
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          Expanded(
            child: RichText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Meu Perfil',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                    ),
                  ),
                  if (fanHandle.isNotEmpty)
                    TextSpan(
                      text: ' · $fanHandle',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
          ),
          MeJamsPill(onPressed: onJams),
          const SizedBox(width: 4),
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
