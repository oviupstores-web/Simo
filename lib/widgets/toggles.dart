import 'package:flutter/material.dart';

import '../theme/theme.dart';
import 'app_icon.dart';
import 'pressable.dart';
import 'thumbs.dart';

/// Puce à cocher (choix multiple : régimes, aliments exclus…).
/// [leading] : vignette ronde (photo ou pastille) ; [icon] + [tint] : icône sur petite pastille.
class ToggleChip extends StatelessWidget {
  const ToggleChip({
    super.key,
    required this.label,
    required this.selected,
    this.onTap,
    this.icon,
    this.tint,
    this.leading,
    this.onRemove,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final String? icon;

  /// Si défini, l'icône est posée sur une pastille de cette famille.
  final Tint? tint;
  final Widget? leading;

  /// Affiche une croix de suppression (aliments exclus).
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.primary : AppColors.ink;
    final Widget? lead =
        leading ??
        (icon == null
            ? null
            : tint != null
            ? TintBadge(icon: icon!, tint: tint!, size: AppSizes.chipBadge, circle: true)
            : AppIcon(icon!, size: 15, color: fg));
    final hasBadge = leading != null || (icon != null && tint != null);
    return Semantics(
      selected: selected,
      button: true,
      child: Pressable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppMotion.normal,
          curve: AppMotion.curve,
          height: AppSizes.chipHeight,
          padding: EdgeInsetsDirectional.only(start: hasBadge ? AppSpace.x1_5 : AppSpace.x3_5, end: AppSpace.x3_5),
          decoration: BoxDecoration(
            color: selected ? AppColors.mint : AppColors.card,
            borderRadius: AppRadius.chipR,
            border: Border.all(color: selected ? AppColors.primary : AppColors.line, width: selected ? 1.5 : 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (lead != null) ...[lead, const SizedBox(width: AppSpace.x2)],
              if (selected && onRemove == null && lead == null) ...[
                AppIcon(AppIcons.check, size: 15, color: fg, strokeWidth: 2.6),
                const SizedBox(width: AppSpace.x1_5),
              ],
              Text(
                label,
                style: AppText.of(AppFont.s13, weight: AppFont.semibold, color: fg, lineHeight: 18),
              ),
              if (selected && onRemove == null && lead != null) ...[
                const SizedBox(width: AppSpace.x1_5),
                AppIcon(AppIcons.check, size: 14, color: fg, strokeWidth: 2.6),
              ],
              if (onRemove != null) ...[
                const SizedBox(width: AppSpace.x1_5),
                GestureDetector(
                  onTap: onRemove,
                  child: AppIcon(AppIcons.close, size: 14, color: fg, strokeWidth: 2.4),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Tuile d'option (équipements, allergènes, catégories, emplacements, mode de récupération) :
/// vignette (photo ou icône sur pastille pastel) + libellé ; sélection = contour vert + coche.
class OptionTile extends StatelessWidget {
  const OptionTile({
    super.key,
    required this.label,
    required this.selected,
    this.icon,
    this.tint = Tint.mint,
    this.leading,
    this.onTap,
    this.subtitle,
    this.vertical = false,
  });

  final String label;
  final bool selected;
  final String? icon;
  final Tint tint;

  /// Vignette personnalisée (photo) à la place de l'icône sur pastille.
  final Widget? leading;
  final VoidCallback? onTap;
  final String? subtitle;

  /// Vignette au-dessus du libellé (tuiles en grille).
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.primary : AppColors.ink;
    final label0 = Text(
      label,
      textAlign: vertical ? TextAlign.center : TextAlign.start,
      style: AppText.of(AppFont.s13, weight: selected ? AppFont.bold : AppFont.semibold, color: fg, lineHeight: 17),
    );
    final badgeSize = vertical ? AppSizes.iconTile : AppSizes.iconTileSm;
    final lead =
        leading ?? (icon == null ? null : TintBadge(icon: icon!, tint: tint, size: badgeSize, circle: vertical));
    return Semantics(
      selected: selected,
      button: true,
      child: Pressable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppMotion.normal,
          curve: AppMotion.curve,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: AppSpace.x2_5, vertical: vertical ? AppSpace.x2_5 : AppSpace.x2),
          decoration: BoxDecoration(
            color: selected ? AppColors.mintTint : AppColors.card,
            borderRadius: AppRadius.chipR,
            border: Border.all(color: selected ? AppColors.primary : AppColors.line, width: selected ? 1.5 : 1),
          ),
          child: vertical
              ? Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ?lead,
                          const SizedBox(height: AppSpace.x1_5),
                          label0,
                          if (subtitle != null)
                            Text(
                              subtitle!,
                              textAlign: TextAlign.center,
                              style: AppText.of(AppFont.s11, color: AppColors.ink2),
                            ),
                        ],
                      ),
                    ),
                    if (selected) const PositionedDirectional(top: 0, end: 0, child: _MiniCheck()),
                  ],
                )
              : Row(
                  children: [
                    if (lead != null) ...[lead, const SizedBox(width: AppSpace.x2_5)],
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Un mot seul ne se coupe jamais : il rétrécit légèrement si besoin.
                          if (label.contains(' '))
                            label0
                          else
                            FittedBox(fit: BoxFit.scaleDown, alignment: AlignmentDirectional.centerStart, child: label0),
                          if (subtitle != null)
                            Text(
                              subtitle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.of(AppFont.s11, color: AppColors.ink2, lineHeight: 15),
                            ),
                        ],
                      ),
                    ),
                    if (selected) ...[const SizedBox(width: AppSpace.x1_5), const _MiniCheck()],
                  ],
                ),
        ),
      ),
    );
  }
}

/// Petite coche verte des tuiles sélectionnées.
class _MiniCheck extends StatelessWidget {
  const _MiniCheck();

  @override
  Widget build(BuildContext context) => Container(
    width: AppSizes.miniCheck,
    height: AppSizes.miniCheck,
    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
    alignment: Alignment.center,
    child: const AppIcon(AppIcons.check, size: 11, color: AppColors.white, strokeWidth: 3),
  );
}

/// Curseur Menoo (budget, temps disponible) : piste mint, partie active verte.
class MenooSlider extends StatelessWidget {
  const MenooSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.divisions,
    this.semanticLabel,
  });

  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: AppSizes.sliderTrack,
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.mint2,
        thumbColor: AppColors.white,
        overlayColor: AppColors.primary.withValues(alpha: 0.12),
        thumbShape: const _RingThumb(),
        trackShape: const RoundedRectSliderTrackShape(),
        tickMarkShape: SliderTickMarkShape.noTickMark,
        showValueIndicator: ShowValueIndicator.never,
      ),
      child: Slider(
        value: value.clamp(min, max),
        min: min,
        max: max,
        divisions: divisions,
        onChanged: onChanged,
        semanticFormatterCallback: semanticLabel == null ? null : (_) => semanticLabel!,
      ),
    );
  }
}

/// Poignée blanche cerclée de vert.
class _RingThumb extends SliderComponentShape {
  const _RingThumb();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size.square(AppSizes.sliderThumb);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    const r = AppSizes.sliderThumb / 2;
    canvas.drawCircle(
      center.translate(0, 2),
      r,
      Paint()
        ..color = AppColors.shadowBtn
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(center, r, Paint()..color = AppColors.white);
    canvas.drawCircle(
      center,
      r - 1.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = AppColors.primary,
    );
  }
}

/// Compteur − valeur + (quantités, portions).
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.value,
    required this.onMinus,
    required this.onPlus,
    this.large = false,
  });

  final String value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final h = large ? AppSizes.inputHeight : AppSizes.chipHeight;
    return Container(
      height: h,
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.x2),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: large ? AppRadius.fieldR : AppRadius.pillR,
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Pressable(
            onTap: onMinus,
            child: Padding(
              padding: const EdgeInsets.all(AppSpace.x1),
              child: AppIcon(AppIcons.minus, size: large ? 20 : 17, color: AppColors.ink2),
            ),
          ),
          SizedBox(
            width: large ? AppSizes.stepperValueW : null,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: large ? 0 : AppSpace.x2),
              child: Text(
                value,
                textAlign: TextAlign.center,
                style: AppText.of(large ? AppFont.s18 : AppFont.s16, weight: AppFont.bold),
              ),
            ),
          ),
          Pressable(
            onTap: onPlus,
            child: Padding(
              padding: const EdgeInsets.all(AppSpace.x1),
              child: AppIcon(AppIcons.plus, size: large ? 20 : 17, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
