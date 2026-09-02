import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class ClockPainter extends CustomPainter {
  ClockPainter({
    required this.dateTime,
    required this.showSecondHand,
  });

  final DateTime dateTime;
  final bool showSecondHand;

  static const double _pi = pi;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final facePaint = Paint()
      ..color = AppColors.clockFace
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, facePaint);

    final ringPaint = Paint()
      ..color = AppColors.clockRing
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius - 1, ringPaint);

    _drawTicks(canvas, center, radius);

    double hour = dateTime.hour % 12 + dateTime.minute / 60.0 + dateTime.second / 3600.0;
    double minute = dateTime.minute + dateTime.second / 60.0;
    double second = dateTime.second + dateTime.millisecond / 1000.0;

    _drawHand(
      canvas,
      center,
      radius,
      hour / 12.0,
      radius * 0.50,
      7.0,
      AppColors.hourHand,
    );
    _drawHand(
      canvas,
      center,
      radius,
      minute / 60.0,
      radius * 0.70,
      4.0,
      AppColors.minuteHand,
    );

    if (showSecondHand) {
      _drawHand(
        canvas,
        center,
        radius,
        second / 60.0,
        radius * 0.80,
        1.5,
        AppColors.secondHand,
      );
    }

    final capPaint = Paint()
      ..color = AppColors.secondHand
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.035, capPaint);

    final capInnerPaint = Paint()..color = AppColors.clockFace;
    canvas.drawCircle(center, radius * 0.012, capInnerPaint);
  }

  void _drawTicks(Canvas canvas, Offset center, double radius) {
    for (int i = 0; i < 60; i++) {
      final angle = (i / 60.0) * 2 * _pi - _pi / 2;
      final isHour = i % 5 == 0;
      final outer = Offset(
        center.dx + cos(angle) * (radius - (isHour ? 14 : 8)),
        center.dy + sin(angle) * (radius - (isHour ? 14 : 8)),
      );
      final inner = Offset(
        center.dx + cos(angle) * (radius - (isHour ? 22 : 13)),
        center.dy + sin(angle) * (radius - (isHour ? 22 : 13)),
      );
      final paint = Paint()
        ..color = isHour ? AppColors.clockRing : AppColors.tickMark
        ..strokeWidth = isHour ? 2.6 : 1.0
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(inner, outer, paint);
    }

    for (int i = 1; i <= 12; i++) {
      final angle = (i / 12.0) * 2 * _pi - _pi / 2;
      final textOffset = Offset(
        center.dx + cos(angle) * (radius - 34),
        center.dy + sin(angle) * (radius - 34),
      );
      final textPainter = TextPainter(
        text: TextSpan(
          text: i == 12 ? 'XII' : i == 1 ? 'I' : i == 2 ? 'II' : i == 3 ? 'III' : i == 4 ? 'IV' : i == 5 ? 'V' : i == 6 ? 'VI' : i == 7 ? 'VII' : i == 8 ? 'VIII' : i == 9 ? 'IX' : i == 10 ? 'X' : 'XI',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: radius * 0.09,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        textOffset - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  void _drawHand(
    Canvas canvas,
    Offset center,
    double radius,
    double fraction,
    double length,
    double width,
    Color color,
  ) {
    final angle = fraction * 2 * _pi - _pi / 2;
    final tip = Offset(
      center.dx + cos(angle) * length,
      center.dy + sin(angle) * length,
    );
    final tail = Offset(
      center.dx - cos(angle) * length * 0.12,
      center.dy - sin(angle) * length * 0.12,
    );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(tail, tip, paint);

    final glow = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawLine(tail, tip, glow);
  }

  @override
  bool shouldRepaint(covariant ClockPainter oldDelegate) {
    return oldDelegate.dateTime != dateTime ||
        oldDelegate.showSecondHand != showSecondHand;
  }
}

class AnalogClock extends StatelessWidget {
  const AnalogClock({
    super.key,
    required this.dateTime,
    this.showSecondHand = true,
    this.size = 260,
  });

  final DateTime dateTime;
  final bool showSecondHand;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: ClockPainter(
        dateTime: dateTime,
        showSecondHand: showSecondHand,
      ),
    );
  }
}
