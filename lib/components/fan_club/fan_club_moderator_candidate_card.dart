import 'package:crowdfans/components/post/post_avatar.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/profile_service.dart';
import 'package:flutter/material.dart';

/// Cartão do candidato na tela Solicitar moderação.
class FanClubModeratorCandidateCard extends StatelessWidget {
  const FanClubModeratorCandidateCard({
    super.key,
    required this.displayName,
    required this.handle,
    required this.photoUrl,
  });

  final String displayName;
  final String handle;
  final String photoUrl;

  String get _handleLabel {
    final normalized = ProfileService.normalizeFanHandle(handle);
    if (normalized.isEmpty) {
      return '';
    }
    return normalized.startsWith('fan/') ? normalized : 'fan/$normalized';
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final handleLabel = _handleLabel;
    return Row(
      children: [
        PostAvatar(url: photoUrl, size: 56),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              if (handleLabel.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  handleLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: colors.textTertiary),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
