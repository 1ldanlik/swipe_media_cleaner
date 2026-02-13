import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_colors.dart';

class CircularProgressIndicatorWidget extends StatelessWidget {
  final double progress;
  final double size;
  final double strokeWidth;

  const CircularProgressIndicatorWidget({
    super.key,
    required this.progress,
    this.size = 80,
    this.strokeWidth = 8,
  });

  @override
  Widget build(BuildContext context) {
    // Корректно вычисляем процент с округлением
    final percentage = (progress.clamp(0.0, 1.0) * 100).round();

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Круговой индикатор прогресса
          CustomPaint(
            size: Size(size, size),
            painter: _CircularProgressPainter(
              progress: progress.clamp(0.0, 1.0),
              strokeWidth: strokeWidth,
            ),
          ),
          // Текст с процентами
          Text(
            '$percentage%',
            style: TextStyle(
              fontSize: size * 0.25,
              fontWeight: FontWeight.bold,
              color: AppColors.greyVeryDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;

  _CircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Рисуем фоновый круг (серый)
    final backgroundPaint = Paint()
      ..color = AppColors.greyLight
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Рисуем прогресс (зеленый)
    final progressPaint = Paint()
      ..color = AppColors.successGreen
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Начинаем с верхней точки (-90 градусов) и рисуем по часовой стрелке
    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Начинаем сверху
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
