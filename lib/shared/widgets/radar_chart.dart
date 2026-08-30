import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/canvas_text.dart';

/// レーダーチャートの 1 軸。
class RadarAxis {
  const RadarAxis({
    required this.label,
    required this.value,
    required this.hasEnoughSamples,
  });

  /// 軸のラベル。3 文字程度に短くする。
  final String label;

  /// 0.0〜1.0。
  final double value;

  /// 判定に足るデータがあるか。少ない軸は薄く描く。
  final bool hasEnoughSamples;
}

/// カテゴリ別の得意・不得意を一目で見せるレーダーチャート。
class RadarChart extends StatelessWidget {
  const RadarChart({super.key, required this.axes, this.size = 240});

  final List<RadarAxis> axes;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (axes.length < 3) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 750),
        curve: Curves.easeOutCubic,
        builder: (context, progress, child) => CustomPaint(
          size: Size.square(size),
          painter: _RadarPainter(
            axes: axes,
            progress: progress,
            textDirection: Directionality.of(context),
            baseStyle: canvasTextStyle(context),
          ),
        ),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  _RadarPainter({
    required this.axes,
    required this.progress,
    required this.textDirection,
    required this.baseStyle,
  });

  final List<RadarAxis> axes;
  final double progress;
  final TextDirection textDirection;
  final TextStyle baseStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // ラベルのぶんだけ内側に描く。
    final radius = size.width / 2 - 26;

    _paintGrid(canvas, center, radius);
    _paintValues(canvas, center, radius);
    _paintLabels(canvas, center, radius);
  }

  double _angleFor(int index) =>
      -math.pi / 2 + index * 2 * math.pi / axes.length;

  Offset _pointFor(Offset center, double radius, int index, double value) {
    final angle = _angleFor(index);
    return Offset(
      center.dx + radius * value * math.cos(angle),
      center.dy + radius * value * math.sin(angle),
    );
  }

  void _paintGrid(Canvas canvas, Offset center, double radius) {
    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColors.border;

    for (final ratio in [0.25, 0.5, 0.75, 1.0]) {
      final path = Path();
      for (var i = 0; i < axes.length; i++) {
        final point = _pointFor(center, radius, i, ratio);
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    for (var i = 0; i < axes.length; i++) {
      canvas.drawLine(center, _pointFor(center, radius, i, 1), gridPaint);
    }

    // 70% の合格ラインを目立たせる。
    final thresholdPath = Path();
    for (var i = 0; i < axes.length; i++) {
      final point = _pointFor(center, radius, i, 0.7);
      if (i == 0) {
        thresholdPath.moveTo(point.dx, point.dy);
      } else {
        thresholdPath.lineTo(point.dx, point.dy);
      }
    }
    thresholdPath.close();
    canvas.drawPath(
      thresholdPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = AppColors.warning.withValues(alpha: 0.45),
    );
  }

  void _paintValues(Canvas canvas, Offset center, double radius) {
    final path = Path();
    for (var i = 0; i < axes.length; i++) {
      final value = axes[i].value.clamp(0.0, 1.0) * progress;
      final point = _pointFor(center, radius, i, value);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    canvas.drawPath(
      path,
      Paint()..color = AppColors.accent.withValues(alpha: 0.26),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round
        ..color = AppColors.accent,
    );

    for (var i = 0; i < axes.length; i++) {
      final axis = axes[i];
      final point = _pointFor(
        center,
        radius,
        i,
        axis.value.clamp(0.0, 1.0) * progress,
      );
      final color = !axis.hasEnoughSamples
          ? AppColors.textMuted
          : axis.value < 0.7
          ? AppColors.danger
          : AppColors.accent;
      canvas.drawCircle(point, 3.4, Paint()..color = color);
    }
  }

  void _paintLabels(Canvas canvas, Offset center, double radius) {
    for (var i = 0; i < axes.length; i++) {
      final axis = axes[i];
      final angle = _angleFor(i);
      final anchor = Offset(
        center.dx + (radius + 15) * math.cos(angle),
        center.dy + (radius + 15) * math.sin(angle),
      );
      final painter = TextPainter(
        text: TextSpan(
          text: axis.label,
          style: baseStyle.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: axis.hasEnoughSamples
                ? AppColors.textSecondary
                : AppColors.textMuted,
          ),
        ),
        textDirection: textDirection,
      )..layout();
      painter.paint(
        canvas,
        anchor - Offset(painter.width / 2, painter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(_RadarPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.axes != axes ||
      oldDelegate.baseStyle != baseStyle;
}
