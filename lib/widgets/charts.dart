import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/formats.dart';
import '../theme/theme.dart';
import 'app_icon.dart';
import 'thumbs.dart';

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

/// « 75 kg aujourd'hui → 70 kg visés, environ 10 semaines à 0,5 kg/semaine ». Réutilisée par
/// `onboarding_profile` (aperçu en direct) et `reassurance_weight` (SPEC §4b).
class WeightProjectionCard extends StatelessWidget {
  const WeightProjectionCard({
    super.key,
    required this.current,
    required this.target,
    required this.weeks,
    required this.rate,
    required this.date,
  });

  final double current;
  final double target;
  final int weeks;
  final double rate;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    TextStyle big(Color c) => AppText.of(AppFont.s22, weight: AppFont.extrabold, color: c, lineHeight: 28);
    return Container(
      padding: const EdgeInsets.all(AppSpace.x4),
      decoration: const BoxDecoration(color: AppColors.mint, borderRadius: AppRadius.cardR),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(Formats.of(context).weight(L.of(context), current), style: big(AppColors.ink)),
                  Text(L.of(context).profileToday, style: AppText.meta),
                ],
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(AppSpace.x3, 0, AppSpace.x3, AppSpace.x4),
                child: AppIcon(AppIcons.arrowRight, size: 22, color: AppColors.primary),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(Formats.of(context).weight(L.of(context), target), style: big(AppColors.primaryDark)),
                  Text(L.of(context).profileTargeted, style: AppText.meta),
                ],
              ),
              const Spacer(),
              const TintBadge(icon: AppIcons.flag, size: AppSizes.iconTile, circle: true),
            ],
          ),
          const SizedBox(height: AppSpace.x2),
          Text(
            L.of(context).profileProjection(weeks, Formats.of(context).rate(L.of(context), rate)),
            style: AppText.of(AppFont.s14, weight: AppFont.bold, lineHeight: 20),
          ),
          Text(L.of(context).profileTargetDate(Formats.of(context).date(date)), style: AppText.caption),
        ],
      ),
    );
  }
}
