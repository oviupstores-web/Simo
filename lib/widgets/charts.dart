import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

/// Anneau de progression (calories), animé à l'affichage.
class ProgressRing extends StatelessWidget {
  const ProgressRing({super.key, required this.value, this.size = AppSizes.ring, this.stroke = 7});

  final double value;
  final double size;
  final double stroke;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0, 1)),
      duration: const Duration(milliseconds: 900),
      curve: AppMotion.curve,
      builder: (_, v, _) => CustomPaint(size: Size.square(size), painter: _RingPainter(v, stroke)),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.value, this.stroke);

  final double value;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2 - stroke / 2 - 2.5; // r = 25 pour 62 px, comme le maître
    final c = size.center(Offset.zero);
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawCircle(c, r, base..color = AppColors.mint2);
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -math.pi / 2,
      2 * math.pi * value,
      false,
      base
        ..color = AppColors.primary
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.value != value;
}

/// Mini-courbe de poids (tracé du maître, 96 × 36).
class WeightSparkline extends StatelessWidget {
  const WeightSparkline({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(AppSizes.sparkW, AppSizes.sparkH), painter: _SparkPainter());
  }
}

class _SparkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // d="M2 8C16 6 22 16 34 15s18 10 30 9 20 8 30 7"
    final p = Path()
      ..moveTo(2, 8)
      ..cubicTo(16, 6, 22, 16, 34, 15)
      ..cubicTo(46, 14, 52, 25, 64, 24)
      ..cubicTo(76, 23, 84, 32, 94, 31);
    canvas.drawPath(
      p,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..color = AppColors.primary,
    );
    canvas.drawCircle(const Offset(94, 31), 3.5, Paint()..color = AppColors.primary);
  }

  @override
  bool shouldRepaint(_SparkPainter old) => false;
}
