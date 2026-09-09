import 'dart:ui' as ui;

import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/artist_analytics_service.dart';
import 'package:flutter/material.dart';

/// Card de gráfico de linha com tendência e estatísticas (prints Insights).
class AnalyticsLineChartCard extends StatelessWidget {
  const AnalyticsLineChartCard({super.key, required this.chart});

  final ArtistAnalyticsChart chart;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final trendPositive = chart.trendPercent >= 0;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chart.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        chart.subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: trendPositive
                        ? AppPalette.green50
                        : AppPalette.red100,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Text(
                      chart.trendBadge,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: trendPositive
                            ? AppPalette.green700
                            : colors.danger,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 140,
              child: CustomPaint(
                painter: _AnalyticsLinePainter(
                  series: chart.series,
                  labels: chart.labels,
                  lineColor: colors.primary,
                  labelColor: colors.textTertiary,
                  fillColor: colors.primary.withValues(alpha: 0.16),
                ),
                child: const SizedBox.expand(),
              ),
            ),
            if (chart.primaryStat != null || chart.secondaryStat != null) ...[
              const SizedBox(height: 12),
              Divider(height: 1, color: colors.border),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (chart.primaryStat != null)
                    Expanded(child: _StatBlock(stat: chart.primaryStat!)),
                  if (chart.primaryStat != null && chart.secondaryStat != null)
                    Container(
                      width: 1,
                      height: 40,
                      color: colors.border,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  if (chart.secondaryStat != null)
                    Expanded(child: _StatBlock(stat: chart.secondaryStat!)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({required this.stat});

  final ArtistAnalyticsChartStat stat;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          stat.formattedValue,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          stat.label,
          style: TextStyle(fontSize: 12, color: colors.textSecondary),
        ),
      ],
    );
  }
}

class _AnalyticsLinePainter extends CustomPainter {
  _AnalyticsLinePainter({
    required this.series,
    required this.labels,
    required this.lineColor,
    required this.labelColor,
    required this.fillColor,
  });

  final List<num> series;
  final List<String> labels;
  final Color lineColor;
  final Color labelColor;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (series.isEmpty) {
      return;
    }
    const labelBand = 18.0;
    final chartHeight = size.height - labelBand;
    final maxValue = series.fold<num>(1, (current, value) {
      return value > current ? value : current;
    });
    final minValue = series.fold<num>(series.first, (current, value) {
      return value < current ? value : current;
    });
    final span = (maxValue - minValue).clamp(1, double.infinity);
    final dx = series.length == 1 ? 0.0 : size.width / (series.length - 1);

    Offset pointFor(int index) {
      final x = dx * index;
      final normalized = (series[index] - minValue) / span;
      final y = chartHeight - (normalized * (chartHeight - 8)) - 4;
      return Offset(x, y.toDouble());
    }

    final path = Path();
    final fillPath = Path();
    for (var i = 0; i < series.length; i++) {
      final point = pointFor(i);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
        fillPath.moveTo(point.dx, chartHeight);
        fillPath.lineTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
        fillPath.lineTo(point.dx, point.dy);
      }
    }
    fillPath
      ..lineTo(pointFor(series.length - 1).dx, chartHeight)
      ..close();

    final fillPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, 0),
        Offset(0, chartHeight),
        [fillColor, fillColor.withValues(alpha: 0.02)],
      );
    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);

    final dotPaint = Paint()..color = lineColor;
    final whitePaint = Paint()..color = Colors.white;
    for (var i = 0; i < series.length; i++) {
      final point = pointFor(i);
      canvas.drawCircle(point, 4.5, whitePaint);
      canvas.drawCircle(point, 3.2, dotPaint);
    }

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (var i = 0; i < series.length; i++) {
      final label = i < labels.length ? labels[i] : '';
      textPainter
        ..text = TextSpan(
          text: label,
          style: TextStyle(fontSize: 10, color: labelColor),
        )
        ..layout();
      final x = (dx * i) - (textPainter.width / 2);
      textPainter.paint(
        canvas,
        Offset(x.clamp(0, size.width - textPainter.width), chartHeight + 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AnalyticsLinePainter oldDelegate) {
    return oldDelegate.series != series ||
        oldDelegate.labels != labels ||
        oldDelegate.lineColor != lineColor;
  }
}
