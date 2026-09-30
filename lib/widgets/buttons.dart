import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_text.dart';
import '../theme/app_tokens.dart';
import 'app_icon.dart';
import 'pressable.dart';

/// Bouton principal : vert, rectangle arrondi 14 px, 54 px de haut, ombre verte.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.showArrow = true,
    this.trailing,
    this.height = AppSizes.btnHeight,
    this.textStyle,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool showArrow;

  /// Remplace la flèche (ex. rond orange de la landing).
  final Widget? trailing;
  final double height;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final end = trailing ?? (showArrow ? const AppIcon(AppIcons.arrowRight, size: 20, color: AppColors.white) : null);
    return Semantics(
      button: true,
      enabled: onPressed != null,
      child: Pressable(
        onTap: onPressed,
        child: AnimatedOpacity(
          duration: AppMotion.normal,
          opacity: onPressed == null ? 0.45 : 1,
          child: Container(
            height: height,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: AppRadius.btnR,
              boxShadow: AppShadows.btn,
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: textStyle ?? AppText.button),
                if (end != null) ...[SizedBox(width: trailing != null ? AppSpace.x3 : AppSpace.x2), end],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Rond orange avec flèche (CTA de la landing — seul usage de l'orange sur un bouton).
class OrangeArrowBadge extends StatelessWidget {
  const OrangeArrowBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.orangeBadge,
      height: AppSizes.orangeBadge,
      decoration: const BoxDecoration(color: AppColors.orange, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: const AppIcon(AppIcons.arrowRight, size: 16, color: AppColors.white),
    );
  }
}

/// Bouton secondaire : contour vert 1,5 px.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: Pressable(
        onTap: onPressed,
        child: Container(
          height: AppSizes.btnSecondaryHeight,
          decoration: BoxDecoration(
            borderRadius: AppRadius.btnR,
            border: Border.all(color: AppColors.primary, width: 1.5),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppText.of(AppFont.s16, weight: AppFont.bold, color: AppColors.primaryDark),
          ),
        ),
      ),
    );
  }
}

/// Bouton de connexion tierce (Google, Apple).
class SocialButton extends StatelessWidget {
  const SocialButton({super.key, required this.label, required this.logoSvg, this.logoSize = 20, this.onPressed});

  final String label;
  final String logoSvg;
  final double logoSize;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onPressed,
      child: Container(
        height: AppSizes.fieldHeight,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppRadius.fieldR,
          border: Border.all(color: AppColors.line),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.string(logoSvg, width: logoSize, height: logoSize),
            const SizedBox(width: AppSpace.x3),
            Text(label, style: AppText.of(AppFont.s15, weight: AppFont.bold)),
          ],
        ),
      ),
    );
  }
}

/// Lien texte souligné vert.
class TextLink extends StatelessWidget {
  const TextLink(this.label, {super.key, this.onTap, this.size = AppFont.s14, this.weight = AppFont.semibold});

  final String label;
  final VoidCallback? onTap;
  final double size;
  final FontWeight weight;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: AppText.of(
          size,
          weight: weight,
          color: AppColors.primary,
        ).copyWith(decoration: TextDecoration.underline, decorationColor: AppColors.primary),
      ),
    );
  }
}
