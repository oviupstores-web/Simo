import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../theme/app_tokens.dart';
import 'app_icon.dart';
import 'pressable.dart';

/// Badge pilule (« Populaire », « À acheter », « En réserve ✓ », « Dans le budget ✓ »…).
class PillBadge extends StatelessWidget {
  const PillBadge(
    this.label, {
    super.key,
    this.background = AppColors.mint,
    this.foreground = AppColors.primary,
    this.size = AppFont.s11,
    this.weight = AppFont.bold,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpace.x2, vertical: AppSpace.x1),
    this.icon,
  });

  /// Badge orange « À acheter / Populaire ».
  const PillBadge.orange(
    this.label, {
    super.key,
    this.size = AppFont.s11,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpace.x2, vertical: AppSpace.x1),
  }) : background = AppColors.orangeSoft,
       foreground = AppColors.warn,
       weight = AppFont.bold,
       icon = null;

  final String label;
  final Color background;
  final Color foreground;
  final double size;
  final FontWeight weight;
  final EdgeInsetsGeometry padding;
  final String? icon;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      label,
      style: AppText.of(size, weight: weight, color: foreground, lineHeight: size * 1.4),
    );
    return Container(
      padding: padding,
      decoration: BoxDecoration(color: background, borderRadius: AppRadius.pillR),
      child: icon == null
          ? text
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppIcon(icon!, size: size + 2, color: foreground, strokeWidth: 2.4),
                const SizedBox(width: AppSpace.x1),
                text,
              ],
            ),
    );
  }
}

/// Étiquette de section (« VOTRE POINT DE DÉPART »).
class EyebrowTag extends StatelessWidget {
  const EyebrowTag({super.key, required this.label, required this.icon});

  final String label;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.x3, vertical: AppSpace.x1),
      decoration: const BoxDecoration(color: AppColors.mint, borderRadius: AppRadius.pillR),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: AppSpace.x1_5),
          Text(
            label,
            style: AppText.of(
              AppFont.s12,
              weight: AppFont.extrabold,
              color: AppColors.primary,
              lineHeight: 16,
            ).copyWith(letterSpacing: 0.3),
          ),
        ],
      ),
    );
  }
}

/// Puce d'information (recette : « Dîner », « 25 min »…).
class InfoChip extends StatelessWidget {
  const InfoChip({super.key, required this.label, required this.icon, this.highlighted = false});

  final String label;
  final String icon;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final fg = highlighted ? AppColors.primary : AppColors.ink;
    return Container(
      height: AppSizes.tagHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.x2_5),
      decoration: BoxDecoration(
        color: highlighted ? AppColors.mint : AppColors.card,
        borderRadius: AppRadius.pillR,
        border: highlighted ? null : Border.all(color: AppColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon(icon, size: 15, color: fg),
          const SizedBox(width: AppSpace.x1_5),
          Text(
            label,
            style: AppText.of(AppFont.s12_5, weight: AppFont.semibold, color: fg, lineHeight: 18),
          ),
        ],
      ),
    );
  }
}

/// Puce de filtre sélectionnable (Réserve : « Tous · 9 », « Frigo · 4 »…).
class FilterPill extends StatelessWidget {
  const FilterPill({super.key, required this.label, this.icon, this.selected = false, this.onTap});

  final String label;
  final String? icon;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.white : AppColors.ink;
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.normal,
        curve: AppMotion.curve,
        height: AppSizes.chipHeight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.x3_5),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.card,
          borderRadius: AppRadius.pillR,
          border: Border.all(color: selected ? AppColors.primary : AppColors.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[AppIcon(icon!, size: 15, color: fg), const SizedBox(width: AppSpace.x1_5)],
            Text(
              label,
              style: AppText.of(AppFont.s13, weight: AppFont.semibold, color: fg, lineHeight: 18),
            ),
          ],
        ),
      ),
    );
  }
}
