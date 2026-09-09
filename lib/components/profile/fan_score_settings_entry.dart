import 'package:crowdfans/components/post/post_avatar.dart';
import 'package:crowdfans/components/profile/fan_score_breakdown_view.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/fan_score.dart';
import 'package:flutter/material.dart';

/// Linha expansível do Fan Score nas settings.
class FanScoreSettingsEntry extends StatelessWidget {
  const FanScoreSettingsEntry({
    super.key,
    required this.entry,
    required this.expanded,
    required this.onToggle,
  });

  final FanScoreEntry entry;
  final bool expanded;
  final VoidCallback onToggle;

  Color accentColor(AppColors colors) {
    final hex = entry.tier.accentColor.trim();
    if (hex.isEmpty) {
      return colors.primaryStrong;
    }
    final normalized = hex.replaceFirst('#', '');
    if (normalized.length != 6) {
      return colors.primaryStrong;
    }
    final value = int.tryParse(normalized, radix: 16);
    if (value == null) {
      return colors.primaryStrong;
    }
    return Color(0xFF000000 | value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final accent = accentColor(colors);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.all(13),
              child: Row(
                children: [
                  PostAvatar(url: entry.artistAvatarUri, size: 52),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.artistName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: colors.textPrimary,
                          ),
                        ),
                        Text(
                          entry.tier.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${entry.currentScore}',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          color: colors.textPrimary,
                        ),
                      ),
                      Text(
                        entry.fanRank == null
                            ? 'Fora do Top 100'
                            : '#${entry.fanRank} no ranking',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    expanded ? Icons.expand_less : Icons.expand_more,
                    color: colors.textTertiary,
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: FanScoreBreakdownView(
                breakdown: entry.breakdown,
                deltaPercentage: entry.deltaPercentage,
              ),
            ),
        ],
      ),
    );
  }
}
