import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/fan_profile.dart';
import 'package:flutter/material.dart';

/// Nome, handle e avatar do perfil público (mock Meu Perfil).
class FanProfileHeader extends StatelessWidget {
  const FanProfileHeader({super.key, required this.profile});

  final FanProfileMeta profile;

  /// Normaliza handle para o formato `fan/...` do mock.
  static String formatHandle(String raw) {
    var value = raw.trim();
    if (value.startsWith('@')) {
      value = value.substring(1).trim();
    }
    if (value.toLowerCase().startsWith('fan/')) {
      return value;
    }
    if (value.isEmpty) {
      return 'fan/';
    }
    return 'fan/$value';
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final avatarUrl = profile.avatarUri.trim();
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: avatarUrl.isEmpty
              ? ColoredBox(
                  color: colors.surfaceAlt,
                  child: const SizedBox(width: 88, height: 88),
                )
              : Image.network(
                  avatarUrl,
                  width: 88,
                  height: 88,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => ColoredBox(
                    color: colors.surfaceAlt,
                    child: const SizedBox(width: 88, height: 88),
                  ),
                ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.displayName.isEmpty ? 'Sem nome' : profile.displayName,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formatHandle(profile.handle),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
