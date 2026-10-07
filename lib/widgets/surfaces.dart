import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_text.dart';
import '../theme/app_tokens.dart';
import 'app_icon.dart';
import 'pressable.dart';

/// Carte blanche, rayon AppRadius.card, ombre très douce.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpace.x4),
    this.onTap,
    this.color = AppColors.card,
    this.border,
    this.shadow = true,
    this.clip = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color color;
  final BoxBorder? border;
  final bool shadow;
  final bool clip;

  @override
  Widget build(BuildContext context) {
    final box = Container(
      padding: padding,
      clipBehavior: clip ? Clip.antiAlias : Clip.none,
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadius.cardR,
        border: border,
        boxShadow: shadow ? AppShadows.card : null,
      ),
      child: child,
    );
    return onTap == null ? box : Pressable(onTap: onTap, scale: 0.99, child: box);
  }
}

/// Pastille d'icône (carré arrondi ou rond, fond teinté).
class IconTile extends StatelessWidget {
  const IconTile({
    super.key,
    required this.icon,
    this.size = AppSizes.iconTile,
    this.iconSize = 24,
    this.background = AppColors.mint,
    this.foreground = AppColors.primary,
    this.circle = false,
    this.radius = AppRadius.tile,
  });

  final String icon;
  final double size;
  final double iconSize;
  final Color background;
  final Color foreground;
  final bool circle;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(radius),
      ),
      alignment: Alignment.center,
      child: AppIcon(icon, size: iconSize, color: foreground),
    );
  }
}

/// Encart d'information (fond mint ou neutre).
class InfoBanner extends StatelessWidget {
  const InfoBanner({
    super.key,
    required this.icon,
    required this.text,
    this.title,
    this.background = AppColors.mint,
    this.iconTopOffset = 0,
    this.textColor = AppColors.ink2,
  });

  final String icon;
  final String? title;
  final String text;
  final Color background;
  final double iconTopOffset;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpace.x4),
      decoration: BoxDecoration(color: background, borderRadius: AppRadius.cardR),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: iconTopOffset),
            child: AppIcon(icon, size: 22, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpace.x3),
          Expanded(
            child: title == null
                ? Text(text, style: AppText.of(AppFont.s13, color: textColor, lineHeight: 19))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title!, style: AppText.of(AppFont.s14, weight: AppFont.bold, lineHeight: 20)),
                      const SizedBox(height: AppSpace.x0_5),
                      Text(text, style: AppText.caption.copyWith(color: textColor)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// Alerte douce (fond orange-soft) : péremption, astuce.
class AlertBanner extends StatelessWidget {
  const AlertBanner({super.key, required this.text, this.icon = AppIcons.clock, this.onTap});

  final InlineSpan text;
  final String icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.99,
      child: Container(
        padding: const EdgeInsets.all(AppSpace.x3_5),
        decoration: const BoxDecoration(color: AppColors.orangeSoft, borderRadius: AppRadius.cardR),
        child: Row(
          children: [
            AppIcon(icon, size: 20, color: AppColors.warn),
            const SizedBox(width: AppSpace.x3),
            Expanded(
              child: Text.rich(text, style: AppText.of(AppFont.s12_5, color: AppColors.alertInk, lineHeight: 18)),
            ),
            const SizedBox(width: AppSpace.x3),
            const AppIcon(AppIcons.chevronRight, size: 16, color: AppColors.warn),
          ],
        ),
      ),
    );
  }
}

/// Jauge horizontale (budget), animée à l'affichage.
class GaugeBar extends StatelessWidget {
  const GaugeBar({super.key, required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.pillR,
      child: Container(
        height: AppSizes.gaugeHeight,
        color: AppColors.mint2,
        alignment: AlignmentDirectional.centerStart,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: value.clamp(0, 1)),
          duration: const Duration(milliseconds: 700),
          curve: AppMotion.curve,
          builder: (_, v, _) => FractionallySizedBox(
            widthFactor: v,
            child: Container(
              decoration: const BoxDecoration(color: AppColors.primary, borderRadius: AppRadius.pillR),
            ),
          ),
        ),
      ),
    );
  }
}

/// Chevron gris des cartes cliquables.
class CardChevron extends StatelessWidget {
  const CardChevron({super.key});

  @override
  Widget build(BuildContext context) => const AppIcon(AppIcons.chevronRight, size: 18, color: AppColors.ink3);
}

/// Petite pastille de couleur (légendes, statuts).
class Dot extends StatelessWidget {
  const Dot(this.color, {super.key});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: AppSizes.dot,
    height: AppSizes.dot,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
