import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/canvas_text.dart';

/// 折れ線の 1 点。
class TrendPoint {
  const TrendPoint({required this.label, required this.value});

  final String label;

  /// 0.0〜1.0。
  final double value;
}

/// 正答率の推移を描くエリアチャート。
///
/// 数字の羅列ではなく「上がっているのか下がっているのか」を形で見せる。
class TrendChart extends StatelessWidget {
  const TrendChart({
    super.key,
    required this.points,
    this.height = 96,
    this.color = AppColors.accent,
  });

  final List<TrendPoint> points;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (points.length < 2) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text(
            'データが増えるとここに推移が出ます',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutCubic,
        builder: (context, progress, child) => CustomPaint(
          size: Size.infinite,
          painter: _TrendPainter(
            points: points,
            color: color,
            progress: progress,
            textDirection: Directionality.of(context),
            baseStyle: canvasTextStyle(context),
          ),
        ),
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  _TrendPainter({
    required this.points,
    required this.color,
    required this.progress,
    required this.textDirection,
    required this.baseStyle,
  });

  final List<TrendPoint> points;
  final Color color;
  final double progress;
  final TextDirection textDirection;
  final TextStyle baseStyle;

  static const double _labelHeight = 16;

  @override
  void paint(Canvas canvas, Size size) {
    final chartHeight = size.height - _labelHeight;
    final stepX = size.width / (points.length - 1);
    double yFor(double value) => chartHeight * (1 - value.clamp(0, 1));

    // 50% / 100% のガイド線。
    final guide = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    for (final value in [0.5, 1.0]) {
      final y = yFor(value);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), guide);
    }

    final visibleCount = (points.length * progress).ceil().clamp(
      2,
      points.length,
    );
    final line = Path();
    final area = Path()..moveTo(0, chartHeight);
    for (var i = 0; i < visibleCount; i++) {
      final offset = Offset(stepX * i, yFor(points[i].value));
      if (i == 0) {
        line.moveTo(offset.dx, offset.dy);
      } else {
        line.lineTo(offset.dx, offset.dy);
      }
      area.lineTo(offset.dx, offset.dy);
    }
    area
      ..lineTo(stepX * (visibleCount - 1), chartHeight)
      ..close();

    canvas.drawPath(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.34), color.withValues(alpha: 0)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, chartHeight)),
    );
    canvas.drawPath(
      line,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color,
    );

    // 最新の点を強調する。
    final last = Offset(
      stepX * (visibleCount - 1),
      yFor(points[visibleCount - 1].value),
    );
    canvas.drawCircle(last, 5.5, Paint()..color = AppColors.surface);
    canvas.drawCircle(last, 4, Paint()..color = color);

    _paintLabel(
      canvas,
      points.first.label,
      0,
      chartHeight,
      Alignment.centerLeft,
    );
    _paintLabel(
      canvas,
      points.last.label,
      size.width,
      chartHeight,
      Alignment.centerRight,
    );
  }

  void _paintLabel(
    Canvas canvas,
    String text,
    double x,
    double chartHeight,
    Alignment alignment,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: baseStyle.copyWith(
          color: AppColors.textMuted,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: textDirection,
    )..layout();
    final dx = alignment == Alignment.centerLeft ? x : x - painter.width;
    painter.paint(canvas, Offset(dx, chartHeight + 3));
  }

  @override
  bool shouldRepaint(_TrendPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.points != points ||
      oldDelegate.baseStyle != baseStyle;
}
