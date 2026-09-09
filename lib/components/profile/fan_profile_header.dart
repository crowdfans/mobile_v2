import 'package:crowdfans/components/post/post_avatar.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/fan_profile.dart';
import 'package:flutter/material.dart';

/// Nome, handle e avatar do perfil público.
class FanProfileHeader extends StatelessWidget {
  const FanProfileHeader({super.key, required this.profile});

  final FanProfileMeta profile;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Row(
      children: [
        PostAvatar(url: profile.avatarUri, size: 72),
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
                profile.handle,
                style: TextStyle(fontSize: 14, color: colors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
