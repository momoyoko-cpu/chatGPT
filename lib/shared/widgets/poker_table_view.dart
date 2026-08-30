import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/canvas_text.dart';
import '../models/position.dart';
import '../models/table_type.dart';

/// テーブルの席を俯瞰で描く図。
///
/// 「BTN vs BB」のような関係を文字で読ませる代わりに、
/// 円卓のどこに座っているかで一目で分かるようにする。
class PokerTableView extends StatelessWidget {
  const PokerTableView({
    super.key,
    required this.tableType,
    required this.heroPosition,
    this.villainPosition,
    this.potLabel,
    this.height = 148,
  });

  final TableType tableType;
  final Position heroPosition;
  final Position? villainPosition;

  /// テーブル中央に出す文字（例: `Pot 5.5BB`）。
  final String? potLabel;
  final double height;

  @override
  Widget build(BuildContext context) {
    final seats = Position.orderFor(tableType);
    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return TweenAnimationBuilder<double>(
            // 席が中心から広がるように現れる。
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 520),
            curve: Curves.easeOutCubic,
            builder: (context, progress, child) {
              return CustomPaint(
                size: Size(constraints.maxWidth, height),
                painter: _PokerTablePainter(
                  seats: seats,
                  heroPosition: heroPosition,
                  villainPosition: villainPosition,
                  potLabel: potLabel,
                  progress: progress,
                  textDirection: Directionality.of(context),
                  baseStyle: canvasTextStyle(context),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _PokerTablePainter extends CustomPainter {
  _PokerTablePainter({
    required this.seats,
    required this.heroPosition,
    required this.villainPosition,
    required this.potLabel,
    required this.progress,
    required this.textDirection,
    required this.baseStyle,
  });

  final List<Position> seats;
  final Position heroPosition;
  final Position? villainPosition;
  final String? potLabel;
  final double progress;
  final TextDirection textDirection;
  final TextStyle baseStyle;

  static const double _seatRadius = 17;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rx = size.width / 2 - _seatRadius - 10;
    final ry = size.height / 2 - _seatRadius - 6;

    _paintFelt(canvas, center, rx, ry);

    final heroIndex = seats.indexOf(heroPosition);
    if (heroIndex < 0) return;

    // ヒーローを手前（下）に置き、以降の席を左隣から時計回りに並べる。
    for (var i = 0; i < seats.length; i++) {
      final position = seats[(heroIndex + i) % seats.length];
      final angle = (math.pi / 2) - (i * 2 * math.pi / seats.length);
      final seatCenter = Offset(
        center.dx + rx * math.cos(angle) * progress,
        center.dy + ry * math.sin(angle) * progress,
      );
      _paintSeat(canvas, seatCenter, position);
    }

    if (potLabel != null) {
      _paintText(
        canvas,
        potLabel!,
        center,
        color: AppColors.textSecondary,
        fontSize: 12,
        weight: FontWeight.w700,
      );
    }
  }

  void _paintFelt(Canvas canvas, Offset center, double rx, double ry) {
    final rect = Rect.fromCenter(
      center: center,
      width: rx * 2 - 12,
      height: ry * 2 - 12,
    );
    canvas.drawOval(
      rect,
      Paint()
        ..style = PaintingStyle.fill
        ..color = AppColors.surfaceHigh,
    );
    canvas.drawOval(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = AppColors.border,
    );
  }

  void _paintSeat(Canvas canvas, Offset seatCenter, Position position) {
    final isHero = position == heroPosition;
    final isVillain = position == villainPosition;

    final Color fill;
    final Color border;
    final Color label;
    if (isHero) {
      fill = AppColors.accent;
      border = AppColors.accent;
      label = const Color(0xFF04231A);
    } else if (isVillain) {
      fill = AppColors.info.withValues(alpha: 0.22);
      border = AppColors.info;
      label = AppColors.info;
    } else {
      fill = AppColors.surface;
      border = AppColors.border;
      label = AppColors.textMuted;
    }

    canvas.drawCircle(seatCenter, _seatRadius, Paint()..color = fill);
    canvas.drawCircle(
      seatCenter,
      _seatRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = isHero || isVillain ? 2 : 1
        ..color = border,
    );

    _paintText(
      canvas,
      position.label,
      seatCenter,
      color: label,
      fontSize: position.label.length > 3 ? 8.5 : 10,
      weight: FontWeight.w800,
    );

    // BTN にはディーラーボタンを添える。
    if (position == Position.btn) {
      final buttonCenter = seatCenter + const Offset(0, -_seatRadius - 7);
      canvas.drawCircle(buttonCenter, 6.5, Paint()..color = Colors.white);
      _paintText(
        canvas,
        'D',
        buttonCenter,
        color: const Color(0xFF16202E),
        fontSize: 8,
        weight: FontWeight.w900,
      );
    }
  }

  void _paintText(
    Canvas canvas,
    String text,
    Offset center, {
    required Color color,
    required double fontSize,
    required FontWeight weight,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: baseStyle.copyWith(
          color: color,
          fontSize: fontSize,
          fontWeight: weight,
        ),
      ),
      textDirection: textDirection,
    )..layout();
    painter.paint(
      canvas,
      center - Offset(painter.width / 2, painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(_PokerTablePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.heroPosition != heroPosition ||
      oldDelegate.villainPosition != villainPosition ||
      oldDelegate.potLabel != potLabel ||
      oldDelegate.seats != seats ||
      oldDelegate.baseStyle != baseStyle;
}
