import 'package:crowdfans/components/post/post_avatar.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/fan_club_viewer_service.dart';
import 'package:flutter/material.dart';

/// Card de expulsão/contestação do viewer.
class FanClubContestationCard extends StatelessWidget {
  const FanClubContestationCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  final FanClubContestation item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final status = switch (item.appealStatus) {
      'pending' => 'Apelação pendente',
      'approved' => 'Apelação aprovada',
      'rejected' => 'Apelação rejeitada',
      _ => 'Sem apelação',
    };
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  PostAvatar(url: item.artistPhotoUrl, size: 44),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.artistName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: colors.surfaceAlt,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: colors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Motivo: ${item.reason}',
                style: TextStyle(fontSize: 13, color: colors.textSecondary),
              ),
              if ((item.appealRejectionReason ?? '').isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Rejeição: ${item.appealRejectionReason}',
                  style: TextStyle(fontSize: 13, color: colors.textSecondary),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                'Abrir Sobre do clube para apelar',
                style: TextStyle(fontSize: 13, color: colors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
