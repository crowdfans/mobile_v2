import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/artist_analytics_service.dart';
import 'package:flutter/material.dart';

Color _colorFromValue(ColorValue value) => Color(value.value);

/// Seção com título/subtítulo em card branco.
class AnalyticsSectionCard extends StatelessWidget {
  const AnalyticsSectionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: colors.textSecondary),
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

/// Barra segmentada + legenda percentual.
class AnalyticsDistributionBar extends StatelessWidget {
  const AnalyticsDistributionBar({super.key, required this.items});

  final List<ArtistAnalyticsDistributionItem> items;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final total = items.fold<num>(0, (sum, item) => sum + item.value);
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            height: 12,
            child: Row(
              children: [
                for (final item in items)
                  Expanded(
                    flex: (item.value * 100).round().clamp(1, 10000),
                    child: ColoredBox(color: _colorFromValue(item.color)),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _colorFromValue(item.color),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  '${item.value.round()}%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        if (total <= 0)
          Text(
            'Sem dados demográficos.',
            style: TextStyle(color: colors.textSecondary),
          ),
      ],
    );
  }
}

/// Lista de barras horizontais (cidades).
class AnalyticsHorizontalBarList extends StatelessWidget {
  const AnalyticsHorizontalBarList({super.key, required this.items});

  final List<ArtistAnalyticsProgressRow> items;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Column(
      children: [
        for (final item in items) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              Text(
                item.value.round().toString(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: (item.value / item.maxValue).clamp(0.04, 1).toDouble(),
              minHeight: 8,
              backgroundColor: colors.surfaceAlt,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

/// Mini pizza com legenda (faixa etária / gênero).
class AnalyticsPieChartCard extends StatelessWidget {
  const AnalyticsPieChartCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.items,
  });

  final String title;
  final String subtitle;
  final List<ArtistAnalyticsDistributionItem> items;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: colors.textSecondary),
            ),
            const SizedBox(height: 12),
            Center(
              child: SizedBox(
                width: 88,
                height: 88,
                child: CustomPaint(painter: _PiePainter(items: items)),
              ),
            ),
            const SizedBox(height: 12),
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: _colorFromValue(item.color),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      '${item.value.round()}%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PiePainter extends CustomPainter {
  _PiePainter({required this.items});

  final List<ArtistAnalyticsDistributionItem> items;

  @override
  void paint(Canvas canvas, Size size) {
    final total = items.fold<num>(0, (sum, item) => sum + item.value);
    if (total <= 0) {
      return;
    }
    final rect = Offset.zero & size;
    var start = -90.0;
    for (final item in items) {
      final sweep = (item.value / total) * 360;
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = _colorFromValue(item.color);
      canvas.drawArc(
        rect.deflate(2),
        start * 3.1415926535 / 180,
        sweep * 3.1415926535 / 180,
        true,
        paint,
      );
      start += sweep;
    }
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.28,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _PiePainter oldDelegate) =>
      oldDelegate.items != items;
}

/// Chips de cidade sob a concentração regional.
class AnalyticsLocationChips extends StatelessWidget {
  const AnalyticsLocationChips({super.key, required this.items});

  final List<ArtistAnalyticsDistributionItem> items;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Column(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.surfaceAlt,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      '${item.value.round()}%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
