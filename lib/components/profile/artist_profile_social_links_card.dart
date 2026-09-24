import 'package:crowdfans/components/profile/artist_profile_social_link_row.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Bloco Outras redes da aba Sobre (só estrutura; sem inventar handles).
class ArtistProfileSocialLinksCard extends StatelessWidget {
  const ArtistProfileSocialLinksCard({
    super.key,
    this.instagramHandle = '',
    this.youtubeHandle = '',
    this.onInstagram,
    this.onYoutube,
  });

  final String instagramHandle;
  final String youtubeHandle;
  final VoidCallback? onInstagram;
  final VoidCallback? onYoutube;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
            child: Text(
              'Outras redes',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
              ),
            ),
          ),
          ArtistProfileSocialLinkRow(
            label: 'Instagram',
            handle: instagramHandle,
            asset: 'assets/images/instagram.svg',
            onPressed: onInstagram,
          ),
          Divider(height: 1, thickness: 0.5, color: colors.border),
          ArtistProfileSocialLinkRow(
            label: 'YouTube',
            handle: youtubeHandle,
            asset: 'assets/images/youtube.svg',
            onPressed: onYoutube,
          ),
        ],
      ),
    );
  }
}
