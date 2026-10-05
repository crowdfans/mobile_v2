import 'package:crowdfans/components/profile/profile_stat_cell.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/profile.dart';
import 'package:flutter/material.dart';

/// Contagem do Meu Perfil no formato pt-BR (`1180` → `1.180`).
String formatProfileCount(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(digits[i]);
  }
  return value < 0 ? '-$buffer' : '$buffer';
}

/// Identidade + stats do perfil na aba Eu (avatar quadrado arredondado).
class ProfileIdentityBlock extends StatelessWidget {
  const ProfileIdentityBlock({
    super.key,
    required this.profile,
    this.onArtistsTap,
  });

  final Profile profile;
  final VoidCallback? onArtistsTap;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final clean = profile.name.trim().replaceAll(RegExp(r'^@'), '');
    final handle = clean.isEmpty
        ? ''
        : (clean.startsWith('fan/') ? clean : 'fan/$clean');
    final url = profile.photoUrl.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              label: 'Foto de perfil',
              image: true,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: url.isEmpty
                    ? ColoredBox(
                        color: colors.surfaceAlt,
                        child: const SizedBox(width: 88, height: 88),
                      )
                    : Image.network(
                        url,
                        width: 88,
                        height: 88,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => ColoredBox(
                          color: colors.surfaceAlt,
                          child: const SizedBox(width: 88, height: 88),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.displayName.isEmpty ? 'Eu' : profile.displayName,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                    ),
                  ),
                  if (handle.isNotEmpty)
                    Text(
                      handle,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colors.textSecondary,
                      ),
                    ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ProfileStatCell(
                        value: formatProfileCount(profile.stats.postsCount),
                        label: 'Posts',
                      ),
                      ProfileStatCell(
                        value: formatProfileCount(profile.stats.cartasCount),
                        label: 'Cartas',
                        divider: true,
                      ),
                      ProfileStatCell(
                        value: formatProfileCount(profile.stats.artistasCount),
                        label: 'Artistas',
                        divider: true,
                        onTap: onArtistsTap,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        if (profile.description.trim().isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            profile.description,
            style: TextStyle(
              fontSize: 14,
              height: 21 / 14,
              color: colors.textPrimary,
            ),
          ),
        ],
      ],
    );
  }
}
