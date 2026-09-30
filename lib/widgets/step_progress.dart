import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../theme/app_tokens.dart';

/// Progression d'onboarding : 4 segments fins formant une fenêtre glissante
/// sur l'ensemble des étapes, + « ÉTAPE X SUR N » à droite.
///
/// À l'arrivée sur un écran, la progression s'anime depuis l'étape précédente :
/// le segment courant se remplit et la fenêtre glisse d'un cran si besoin.
class StepProgress extends StatelessWidget {
  const StepProgress({super.key, required this.step, required this.total});

  final int step;
  final int total;

  /// Nombre de segments visibles.
  static const window = 4;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: (step - 1).toDouble(), end: step.toDouble()),
            duration: AppMotion.progress,
            curve: AppMotion.curve,
            builder: (context, value, _) => _SlidingSegments(progress: value, total: total),
          ),
        ),
        const SizedBox(width: AppSpace.x3),
        Text('ÉTAPE $step SUR $total', style: AppText.stepLabel),
      ],
    );
  }
}

class _SlidingSegments extends StatelessWidget {
  const _SlidingSegments({required this.progress, required this.total});

  /// Nombre d'étapes remplies (continu pendant l'animation).
  final double progress;
  final int total;

  @override
  Widget build(BuildContext context) {
    const n = StepProgress.window;
    const gap = AppSpace.x1_5;
    // La fenêtre commence de sorte que l'étape en cours soit le 3e segment,
    // bornée au début et à la fin du parcours.
    final start = (progress - (n - 1)).clamp(0.0, (total - n).toDouble());
    final first = start.floor();
    final shift = start - first;

    return LayoutBuilder(
      builder: (context, c) {
        final segW = (c.maxWidth - gap * (n - 1)) / n;
        return ClipRect(
          child: SizedBox(
            height: AppSizes.progressSegment,
            child: OverflowBox(
              alignment: Alignment.centerLeft,
              maxWidth: double.infinity,
              child: Transform.translate(
                offset: Offset(-shift * (segW + gap), 0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i <= n && first + i < total; i++) ...[
                      if (i > 0) const SizedBox(width: gap),
                      _Segment(width: segW, fill: (progress - (first + i)).clamp(0.0, 1.0)),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.width, required this.fill});

  final double width;
  final double fill;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.pillR,
      child: Container(
        width: width,
        height: AppSizes.progressSegment,
        color: AppColors.line,
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: fill,
          child: Container(color: AppColors.primary),
        ),
      ),
    );
  }
}
