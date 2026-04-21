import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class LineGraph extends StatelessWidget {
  final List<double> values;
  final List<String> labels;

  const LineGraph({
    super.key,
    required this.values,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LineGraphPainter(values: values, labels: labels),
      child: const SizedBox.expand(),
    );
  }
}

class _LineGraphPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;

  _LineGraphPainter({required this.values, required this.labels});

  static const double _minY = 70;
  static const double _maxY = 100;

  @override
  void paint(Canvas canvas, Size size) {
    const leftPad = 34.0;
    const rightPad = 14.0;
    const topPad = 22.0;
    const bottomPad = 26.0;

    final graphLeft = leftPad;
    final graphRight = size.width - rightPad;
    final graphTop = topPad;
    final graphBottom = size.height - bottomPad;
    final graphWidth = graphRight - graphLeft;
    final graphHeight = graphBottom - graphTop;

    // ── Grid lines ──
    for (final yVal in [70, 80, 90, 100]) {
      final frac = (yVal - _minY) / (_maxY - _minY);
      final y = graphBottom - frac * graphHeight;

      // Dashed line
      final dashPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.08)
        ..strokeWidth = 0.8;

      double dx = graphLeft;
      while (dx < graphRight) {
        final end = (dx + 4).clamp(dx, graphRight);
        canvas.drawLine(Offset(dx, y), Offset(end, y), dashPaint);
        dx += 8;
      }

      // Y label
      final tp = TextPainter(
        text: TextSpan(
          text: '$yVal',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.35),
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(graphLeft - tp.width - 6, y - tp.height / 2));
    }

    if (values.isEmpty) return;

    // ── Calculate points ──
    final points = <Offset>[];
    for (int i = 0; i < values.length; i++) {
      final x = values.length == 1
          ? graphLeft + graphWidth / 2
          : graphLeft + (i / (values.length - 1)) * graphWidth;
      final frac = ((values[i] - _minY) / (_maxY - _minY)).clamp(0.0, 1.0);
      final y = graphBottom - frac * graphHeight;
      points.add(Offset(x, y));
    }

    // ── Gradient fill ──
    final fillPath = Path()..moveTo(points.first.dx, graphBottom);
    for (final p in points) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(points.last.dx, graphBottom);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, graphTop),
          Offset(0, graphBottom),
          [
            Colors.white.withValues(alpha: 0.15),
            Colors.white.withValues(alpha: 0.02),
          ],
        ),
    );

    // ── Smooth line ──
    if (points.length > 1) {
      final linePath = Path()..moveTo(points.first.dx, points.first.dy);

      // Catmull-Rom to cubic bezier for smooth curve
      for (int i = 0; i < points.length - 1; i++) {
        final p0 = i > 0 ? points[i - 1] : points[i];
        final p1 = points[i];
        final p2 = points[i + 1];
        final p3 = i < points.length - 2 ? points[i + 2] : points[i + 1];

        final cp1 = Offset(
          p1.dx + (p2.dx - p0.dx) / 6,
          p1.dy + (p2.dy - p0.dy) / 6,
        );
        final cp2 = Offset(
          p2.dx - (p3.dx - p1.dx) / 6,
          p2.dy - (p3.dy - p1.dy) / 6,
        );

        linePath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
      }

      // Glow line
      canvas.drawPath(
        linePath,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.2)
          ..strokeWidth = 6
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );

      // Main line
      canvas.drawPath(
        linePath,
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }

    // ── Dots and value labels ──
    for (int i = 0; i < points.length; i++) {
      // Glow
      canvas.drawCircle(
        points[i],
        10,
        Paint()..color = Colors.white.withValues(alpha: 0.1),
      );
      // Outer ring
      canvas.drawCircle(
        points[i],
        5.5,
        Paint()..color = Colors.white,
      );
      // Inner fill
      canvas.drawCircle(
        points[i],
        3.5,
        Paint()..color = const Color(0xFF4F46E5),
      );

      // Value label above
      final valueTp = TextPainter(
        text: TextSpan(
          text: values[i].toStringAsFixed(1),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      valueTp.paint(
        canvas,
        Offset(
          points[i].dx - valueTp.width / 2,
          points[i].dy - valueTp.height - 12,
        ),
      );
    }

    // ── X-axis labels ──
    for (int i = 0; i < labels.length && i < points.length; i++) {
      final labelTp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      labelTp.paint(
        canvas,
        Offset(points[i].dx - labelTp.width / 2, graphBottom + 8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LineGraphPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.labels != labels;
  }
}
