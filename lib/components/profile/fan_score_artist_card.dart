import 'package:crowdfans/components/post/post_avatar.dart';
import 'package:crowdfans/components/profile/fan_score_breakdown_view.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/fan_score.dart';
import 'package:flutter/material.dart';

/// Cartão de Fan Score por artista (gradiente + insights).
class FanScoreArtistCard extends StatelessWidget {
  const FanScoreArtistCard({
    super.key,
    required this.entry,
    required this.expanded,
    required this.onToggleInsights,
  });

  final FanScoreEntry entry;
  final bool expanded;
  final VoidCallback onToggleInsights;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final gradient = _parseGradient(entry.tier.gradient, [
      colors.surfaceAlt,
      colors.surface,
    ]);
    final badgeGradient = _parseGradient(entry.tier.badgeGradient, gradient);
    final border = _parseHex(entry.tier.border) ?? colors.border;
    final badgeText =
        _parseHex(entry.tier.badgeText) ?? const Color(0xFF111827);
    final deltaColor = entry.deltaPercentage > 0
        ? const Color(0xFF15803D)
        : entry.deltaPercentage < 0
        ? const Color(0xFFB91C1C)
        : const Color(0xFF374151);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: border),
                gradient: LinearGradient(colors: badgeGradient),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                child: Text(
                  entry.tier.label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: badgeText,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                PostAvatar(url: entry.artistAvatarUri, size: 44),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.artistName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      Text(
                        '${entry.memberCount} membros',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onToggleInsights,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0x8CFFFFFF),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: colors.border),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Text(
                        expanded ? 'Fechar' : 'Insights',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatScore(entry.currentScore),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatDelta(entry.deltaPercentage),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: deltaColor,
                      ),
                    ),
                    Text(
                      entry.fanRank == null
                          ? 'Sem ranking'
                          : '#${entry.fanRank}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (expanded) ...[
              const SizedBox(height: 12),
              const Divider(color: Color(0x33111127), height: 1),
              const SizedBox(height: 10),
              FanScoreBreakdownView(breakdown: entry.breakdown),
            ],
          ],
        ),
      ),
    );
  }
}

Color? _parseHex(String raw) {
  var hex = raw.trim();
  if (hex.isEmpty) {
    return null;
  }
  if (hex.startsWith('#')) {
    hex = hex.substring(1);
  }
  if (hex.length == 3) {
    hex = hex.split('').map((c) => '$c$c').join();
  }
  if (hex.length == 6) {
    hex = 'FF$hex';
  }
  if (hex.length != 8) {
    return null;
  }
  return Color(int.parse(hex, radix: 16));
}

List<Color> _parseGradient(List<String> raw, List<Color> fallback) {
  final parsed = [
    for (final item in raw)
      if (_parseHex(item) != null) _parseHex(item)!,
  ];
  if (parsed.length < 2) {
    return fallback;
  }
  return parsed;
}

String _formatScore(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer(value < 0 ? '-' : '');
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

String _formatDelta(int delta) {
  if (delta > 0) {
    return '+$delta%';
  }
  if (delta < 0) {
    return '$delta%';
  }
  return '0%';
}
